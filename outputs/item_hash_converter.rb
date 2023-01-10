module Outputs
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
        categories: categories,
        recipe: recipe
      }
    end

    def to_h
      convert
    end

    private

    def id
      @id ||= @item_struct.name.parameterize.to_sym
    end

    def name
      @name ||= @item_struct.name
    end

    def level
      @level ||= @item_struct.level
    end

    def value
      @value ||= @item_struct.value
    end

    def innate_categories
      (0...4)
        .map { |n| @item_struct.send("category#{n}") }
        .filter_map { |cat_string| category_from_cat_string cat_string }
    end

    def optional_categories
      (0...4)
        .map { |n| @item_struct.send("effect#{n}") }
        .filter do |eff|
          eff.present? && eff.any? { |eff_s| eff_s.start_with?("Add (") }
        end
        .flat_map
        .with_index do |eff, index|
          eff.map do |eff_string|
            category_from_cat_string eff_string[4..-1], slot: index
          end
        end
    end

    def category_from_cat_string(cat_string, slot: nil)
      return if cat_string.nil?

      {
        id: cat_string.parameterize,
        name: cat_string[1..-2],
        slot: slot
      }.compact
    end

    def categories
      @categories ||= innate_categories + optional_categories
    end

    def materials
      @materials ||= (0...4).map { |n| @item_struct.send("material#{n}") }
    end

    def recipe_items
      materials
        .reject { |s| s.start_with? "(" }
        .map(&:parameterize)
        .to_h { |item_id| [item_id.to_sym, { id: item_id, amount: 1 }] }
    end

    def recipe_categories
      materials
        .select { |s| s.start_with? "(" }
        .map(&:parameterize)
        .to_h do |category_id|
          [category_id.to_sym, { id: category_id, amount: 1 }]
        end
    end

    def recipe
      { id: id, items: recipe_items, categories: recipe_categories }
    end
  end
end
