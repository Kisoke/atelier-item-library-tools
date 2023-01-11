require "pathname"

require "active_support"
require "active_support/core_ext/string/inquiry"

module Inputs
  class LibraryImagesFolder
    TEMP_IMAGES_DIR = "#{INPUT_FOLDER}/temp".freeze

    def self.with_library_item_entries(parent_dir)
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

    def initialize(parent_dir)
      @parent_dir = parent_dir
    end

    def entries
      return @entries if @entries

      @entries = []

      LibraryImagesFolder.with_library_item_entries(
        @parent_dir
      ) do |item_image_path, item_effects_image_path|
        entries.push(
          {
            item: item_image_path.freeze,
            effects: item_effects_image_path.freeze
          }.freeze
        )
      end

      @entries.freeze
    end
  end
end
