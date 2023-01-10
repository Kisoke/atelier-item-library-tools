#!/usr/bin/env ruby
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

require "./utils/library_extractor_config"
require "./utils/image_item_extractor"
require "./utils/item_hash_converter"

SCRIPT_VERSION = "0.1.0"
SCRIPT_URL = "https://script-url.example.com"

def credits_hash
  {
    generated: Time.now.to_s,
    tesseract_version: tesseract_version,
    script: SCRIPT_URL,
    script_version: SCRIPT_VERSION,
    ruby_version: `ruby -v`.strip
  }
end

def with_library_item_entries(parent_dir)
  parent_path = Pathname.new("library/#{parent_dir}")

  entries =
    Dir
      .entries(parent_path.to_s)
      .filter { |entry| entry.split(".").last }
      .map { |file_name| Pathname.new("#{parent_path}/#{file_name}") }
      .filter { |path| path.file? && path.extname == ".png" }

  entries.each.with_index do |image_path, index|
    next if index.odd? && parent_dir.inquiry.mix?

    filename = image_path.basename.to_s.split(".").first
    effects_image_path =
      if parent_dir.inquiry.mix?
        Pathname.new("#{entries[index + 1]}").realpath
      end

    yield(image_path, effects_image_path)
  end
end

def library_extract
  # remove old tempfiles
  FileUtils.rm_rf(TEMP_IMAGES_DIR)
  Dir.mkdir(TEMP_IMAGES_DIR)

  @extracted_items = []

  with_library_item_entries("mix") do |item_image_path, item_effects_image_path|
    extractor = ImageItemExtractor.new(item_image_path, item_effects_image_path)

    @extracted_items.push(extractor.value)
  end

  @converted_items =
    @extracted_items.map { |item| ItemHashConverter.new(item).to_h }

  @recipes = @converted_items.to_h { |item| [item[:id], item.delete(:recipe)] }

  File.write("recipes.json", { items: @recipes, credits: credits_hash }.to_json)
  File.write(
    "items.json",
    { items: @converted_items, credits: credits_hash }.to_json
  )
end

library_extract
