# typed: true
require "rubygems"
require "bundler/setup"

require "nokogiri"
require "active_support"
require "active_support/core_ext/string/inflections"
require "active_support/core_ext/string/filters"

require "byebug"

# Use this file with a data/saves export of game data next to it.

@lang = "en"

ITEMDATA_PATH = "data/saves/item".freeze
DEFAULT_STRINGS_PATH = "data/saves/text_en".freeze
STRINGS_PATH = "data/saves/text_#{@lang}".freeze

ITEMDATA_RECIPES_PATH = "#{ITEMDATA_PATH}/itemrecipedata.xml".freeze
ITEMDATA_ITEMS_PATH = "#{ITEMDATA_PATH}/itemdata.xml".freeze
ITEMDATA_EFFECTS_PATH = "#{ITEMDATA_PATH}/item_effect.xml".freeze
ITEMDATA_TRAITS_PATH = "#{ITEMDATA_PATH}/item_potential.xml".freeze

DEFAULT_ITEM_STRINGS_PATH = "#{DEFAULT_STRINGS_PATH}/str_item_name.xml".freeze
ITEM_STRINGS_PATH = "#{STRINGS_PATH}/str_item_name.xml".freeze
CATEGORIES_STRINGS_PATH = "#{STRINGS_PATH}/str_item_category.xml".freeze
EFFECTS_STRINGS_PATH = "#{STRINGS_PATH}/str_item_effect.xml".freeze
TRAITS_STRINGS_PATH = "#{STRINGS_PATH}/str_item_potential.xml".freeze

@recipe_list = { recipes: {} }

@item_list = { items: {} }

def filter_root_elements(xml_data)
  xml_data.root.children.select { |e| e.is_a?(Nokogiri::XML::Element) }
end

@recipe_data =
  filter_root_elements Nokogiri.XML(File.open(ITEMDATA_RECIPES_PATH))
@item_data = filter_root_elements Nokogiri.XML(File.open(ITEMDATA_ITEMS_PATH))
@effect_data =
  filter_root_elements Nokogiri.XML(File.open(ITEMDATA_EFFECTS_PATH))
@trait_data = filter_root_elements Nokogiri.XML(File.open(ITEMDATA_TRAITS_PATH))

@item_string_data =
  filter_root_elements Nokogiri.XML(File.open(ITEM_STRINGS_PATH))
@category_string_data =
  filter_root_elements Nokogiri.XML(File.open(CATEGORIES_STRINGS_PATH))
@effect_string_data =
  filter_root_elements Nokogiri.XML(File.open(EFFECTS_STRINGS_PATH))
@traits_string_data =
  filter_root_elements Nokogiri.XML(File.open(TRAITS_STRINGS_PATH))

def get_id_for_item_tag(item_tag)
  @item_string_data
    .find { |e| e.attr("String_ID") == item_tag }
    .attr("Text")
    .parameterize
    .to_sym
end

def get_id_for_category_tag(category_tag)
  category_tag.remove("ITEM_CATEGORY_").parameterize.to_sym
end

def extract_item(xml_item)
  item = {
    type: :a23_item,
    id: get_id_for_item_tag(xml_item.attr("nameID")),
    image: "a23_item_l_#{xml_item.attr("imgNo")}",
    level: xml_item.attr("lv").to_i,
    value: xml_item.attr("price").to_i,
    categories: (0..3).filter_map { extract_category(xml_item, n) }
  }

  item
end

def extract_category(xml_item, n = nil)
  category_tag = xml_item.attr("cat_#{n}")

  return unless n

  category = { type: :a23_category, id: get_id_for_category_tag(category_tag) }
end

@item_data.each { |data| extract_category(data) }

@item_list[:items].push extract_item(@item_data.first)

lol = "mdr"
