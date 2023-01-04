# typed: true
require "rubygems"
require "bundler/setup"

require "active_support"
require "active_support/core_ext/string/inflections"
require "active_support/core_ext/string/filters"
require "active_support/core_ext/string/inquiry"

require "pathname"
require "fileutils"
require "json"

require "rtesseract"
require "rmagick"

require "byebug"

require "./config"

module ImageTransformers
  class Transform
    def initialize(**kwargs)
      @options = OpenStruct.new(kwargs)
    end
  end

  class Crop < Transform
    def initialize(x: 0, y: 0, width: 10, height: 10)
      super
    end

    def apply(image)
      image.crop(@options.x, @options.y, @options.width, @options.height)
    end
  end

  class Grayscale < Transform
    def initialize(color_bits: 256)
      super
    end

    def apply(image)
      image.quantize(@options.color_bits, Magick::GRAYColorspace)
    end
  end

  class Contrast < Transform
    def initialize(
      black_point: 0,
      white_point: Magick::QuantumRange,
      channel: Magick::DefaultChannels
    )
      super
    end

    def apply(image)
      image.contrast_stretch_channel(
        @options.black_point,
        @options.white_point,
        @options.channel
      )
    end
  end
end

class ImageAttributeExtractor
  attr_accessor :id
  attr_accessor :image

  def initialize(**kwargs)
    @image_path = image_path
    @image =
      if kwargs[:image]
        kwargs[:image]
      else
        Magick::ImageList.new(kwargs[:image_path].realpath)
      end
    @options = JSON.parse kwargs.to_json, object_class: OpenStruct

    @transformed_image = false
  end

  def extract
    prepared_image_path = Pathname.new("#{images_dir}/#{attribute}.png")
    transform_image.write(prepared_image_path)

    @extracted = "lol" # extract data with tesseract
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
        **transform.parameters
      )
    end
  end
end

class ImageItemExtractor
  def initialize(item_library_image_path)
    @item_image_path =
      if item_library_image_path.is_a? String
        Pathname.new(item_library_image_path).realpath
      else
        item_library_image_path
      end

    @item = OpenStruct.new
  end

  def extract
    ITEM_ATTRIBUTES_EXTRACTION_CONFIG.each_key do |attribute|
      attr_extractor =
        ImageAttributeExtractor.new(
          ITEM_ATTRIBUTES_EXTRACTION_CONFIG[attribute]
        )

      @item.send("#{attribute}=", attr_extractor.extract)
    end
  end
end

TEMP_IMAGES_DIR = "library/temp".freeze
NUMBERS_PATTERN_PATH =
  Pathname.new("library/patterns/numbers_pattern.txt").realpath.freeze
CATEGORIES_PATTERN_PATH =
  Pathname.new("library/patterns/categories_pattern.txt").realpath.freeze

def extract_item_data_from_library_image(
  main_page_image_path,
  effects_page_image_path: nil
)
  raise ArgumentError unless main_page_image_path.file?

  item = {}

  images_dir =
    "#{TEMP_IMAGES_DIR}/#{main_page_image_path.basename.to_s.split(".").first}"
  Dir.mkdir(images_dir)
  source =
    Magick::ImageList.new(main_page_image_path.to_s).quantize(
      256,
      Magick::GRAYColorspace
    )
  # .contrast_stretch_channel(0, Magick::QuantumRange)

  ITEM_BOUNDING_RECTANGLES_CONFIG.keys.each do |attribute|
    result =
      source.crop(*ITEM_BOUNDING_RECTANGLES_CONFIG[attribute][:rectangle])

    result.write("#{images_dir}/#{attribute}.png")
  end

  ITEM_BOUNDING_RECTANGLES_CONFIG.keys.each do |attribute|
    data =
      case ITEM_BOUNDING_RECTANGLES_CONFIG[attribute][:type]
      when :integer
        RTesseract
          .new(
            "#{images_dir}/#{attribute}.png",
            config_file: :digits,
            psm: 13,
            lang: :eng,
            tessedit_char_blacklist: "|=!/\\[]"
          )
          .to_s
          .strip
          .to_i
      when :category
        RTesseract
          .new(
            "#{images_dir}/#{attribute}.png",
            user_patterns: CATEGORIES_PATTERN_PATH.to_s,
            lang: :eng,
            tessedit_char_blacklist: "|=!/\\[]"
          )
          .to_s
          .strip
          .parameterize
      else
        RTesseract
          .new(
            "#{images_dir}/#{attribute}.png",
            psm: 13,
            lang: :eng,
            tessedit_char_blacklist: "|=!/\\[]"
          )
          .to_s
          .strip
          .parameterize
      end

    item[attribute] = data
  end

  item[:effects] = extract_item_effects_from_library_image(
    effects_page_image_path
  ) if effects_page_image_path.present?

  item
end

def extract_item_effects_from_library_image(effects_page_image_path)
  effects = []

  source =
    Magick::ImageList.new(effects_page_image_path.to_s).quantize(
      256,
      Magick::GRAYColorspace
    )

  images_dir =
    "#{TEMP_IMAGES_DIR}/#{effects_page_image_path.basename.to_s.split(".").first}"

  EFFECT_BOUNDING_RECTANGLES_CONFIG.each { |rectangle| }
end

FileUtils.rm_rf(TEMP_IMAGES_DIR)
Dir.mkdir(TEMP_IMAGES_DIR)

@extracted_items = []
Dir
  .entries("library")
  .filter { |entry| entry.split(".").last }
  .filter { |file_name| file_name.split(".").last.inquiry.png? }
  .map { |file_name| Pathname.new("library/#{file_name}") }
  .each do |image_path|
    extracted_item = extract_item_data_from_library_image(image_path)

    @extracted_items.push extracted_item
  end
byebug

lol = "mdr"
