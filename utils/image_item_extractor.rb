require "./utils/image_attribute_extractor"

class ImageItemExtractor
  def initialize(item_library_image_path, item_effects_library_image_path = nil)
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

    ITEM_ATTRIBUTES_EXTRACTION_CONFIG.each_key do |attribute|
      attr_extractor =
        ImageAttributeExtractor.new(
          image_path: @item_image_path,
          attribute: attribute,
          **ITEM_ATTRIBUTES_EXTRACTION_CONFIG[attribute]
        )

      @item.send("#{attribute}=", attr_extractor.value)
    end

    ITEM_EFFECTS_EXTRACTION_CONFIG.each_key do |effect|
      effect_extractor =
        ImageAttributeExtractor.new(
          image_path: @item_effects_image_path,
          attribute: effect,
          **ITEM_EFFECTS_EXTRACTION_CONFIG[effect]
        )

      @item.send("#{effect}=", effect_extractor.value)
    end

    @extracted = @item
  end

  def value
    extract unless @extracted

    @item
  end
end
