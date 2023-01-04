require "pathname"
require "rmagick"
require "json"

require "./utils/image_text_extractor"
require "./utils/image_transformers"

TEMP_IMAGES_DIR = "library/temp".freeze

class ImageAttributeExtractor
  attr_accessor :image

  def initialize(**kwargs)
    @image_path = kwargs[:image_path].realpath
    @image = Magick::ImageList.new(@image_path)
    @options = JSON.parse kwargs.to_json, object_class: OpenStruct

    @transformed_image = false
  end

  def extract
    return @extracted if @extracted

    prepared_image_path =
      Pathname.new("#{images_dir}/#{@options.attribute}.png")
    transform_image.write(prepared_image_path)

    @extractor_class =
      case @options.tesseract_type&.to_sym
      when :integer
        ImageIntegerExtractor
      when :category
        ImageCategoryExtractor
      else
        ImageStringExtractor
      end

    @extractor = @extractor_class.new(prepared_image_path)

    @extracted = @extractor.value
  end

  def value
    extract unless @extracted

    @extracted
  end

  private

  def images_dir
    @images_dir ||=
      "#{TEMP_IMAGES_DIR}/#{@image_path.basename.to_s.split(".").first}"
    Dir.mkdir(@images_dir) unless Dir.exists?(@images_dir)

    @images_dir
  end

  def transform_image
    @transformed_image ||=
      @options
        .transforms
        .reduce(@image) do |transformed_image, transform|
          get_transform(transform).apply(transformed_image)
        end
  end

  def get_transform(transform)
    if transform.is_a? String
      "#{ImageTransformers}::#{transform.classify}".constantize.new
    else
      "#{ImageTransformers}::#{transform.type.classify}".constantize.new(
        **transform.parameters.to_h
      )
    end
  end
end
