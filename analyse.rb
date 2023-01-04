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

require "byebug"

require "./utils/config"
require "./utils/image_item_extractor"

FileUtils.rm_rf(TEMP_IMAGES_DIR)
Dir.mkdir(TEMP_IMAGES_DIR)

def with_library_item_entries
  entries =
    Dir
      .entries("library")
      .filter { |entry| entry.split(".").last }
      .map { |file_name| Pathname.new("library/#{file_name}") }
      .filter { |path| path.file? && path.extname == ".png" }
      .each do |image_path|
        filename = image_path.basename.to_s.split(".").first
        effects_image_path =
          if File.exists?("library/#{filename}.effects")
            Pathname.new("library/#{filename}.effects").realpath
          end

        yield(image_path, effects_image_path)
      end
end

@extracted_items = []

with_library_item_entries do |item_image_path, item_effects_image_path|
  extractor = ImageItemExtractor.new(item_image_path, item_effects_image_path)

  @extracted_items.push(extractor.value)
end

byebug

lol = "mdr"
