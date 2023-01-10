require "./processors/library_images_tesseract/image_attribute_extractor"

module Processors
  module LibraryImagesTesseract
    class ImageItemExtractor
      def initialize(
        item_library_image_path,
        item_effects_library_image_path = nil
      )
        @item_image_path =
          if item_library_image_path.is_a? String
            Pathname.new(item_library_image_path).realpath
          else
            item_library_image_path
          end

        @item_effects_image_path = item_effects_library_image_path

        @item = OpenStruct.new
      end

      def extract
        return @extracted if @extracted

        extract_item_attributes

        extract_item_recipe if @item_effects_image_path.present?
        extract_item_effects if @item_effects_image_path.present?

        @extracted = @item
      end

      def value
        extract unless @extracted

        @item
      end

      private

      def extract_item_attributes
        extract_with_configuration(
          @item_image_path,
          ITEM_ATTRIBUTES_EXTRACTION_CONFIG
        )
      end

      def extract_item_recipe
        extract_with_configuration(
          @item_image_path,
          ITEM_RECIPE_EXTRACTION_CONFIG
        )
      end

      def extract_item_effects
        extract_with_configuration(
          @item_effects_image_path,
          ITEM_EFFECTS_EXTRACTION_CONFIG
        )
      end

      def extract_with_configuration(source_image, config)
        config.each_key do |config_key|
          effect_extractor =
            ImageAttributeExtractor.new(
              image_path: source_image,
              attribute: config_key,
              **config[config_key]
            )

          @item.send("#{config_key}=", effect_extractor.value)
        end
      end
    end
  end
end
