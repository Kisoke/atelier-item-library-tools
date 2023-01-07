class ItemHashConverter
  def initialize(item_struct, no_eager_conversion: false)
    @item_struct = item_struct

    convert unless no_eager_conversion
  end

  def convert
    @converted ||= {
      id: id,
      name: name,
      level: level,
      value: value,
      categories: categories
    }
  end

  def to_h
    convert
  end

  private

  def id
    @item_struct.name.parameterize
  end

  def name
    @item_struct.name
  end

  def level
    @item_struct.level
  end

  def value
    @item_struct.value
  end

  def innate_categories
    [
      @item_struct.category0,
      @item_struct.category1,
      @item_struct.category2,
      @item_struct.category3
    ].compact.map { |cat_string| category_from_cat_string cat_string }
  end

  def optional_categories
    [
      @item_struct.effect0,
      @item_struct.effect1,
      @item_struct.effect2,
      @item_struct.effect3
    ].filter { |eff| eff.any? { |eff_s| eff_s.start_with?("Add (") } }
      .flat_map
      .with_index do |eff, index|
        eff.map do |eff_string|
          category_from_cat_string eff_string[4..-1], slot: index
        end
      end
  end

  def category_from_cat_string(cat_string, slot: nil)
    { id: cat_string.parameterize, name: cat_string[1..-2], slot: slot }.compact
  end

  def categories
    innate_categories + optional_categories
  end
end
