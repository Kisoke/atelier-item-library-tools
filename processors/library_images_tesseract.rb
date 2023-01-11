require "./config/library_images_tesseract_config"
require "./processors/library_images_tesseract/image_item_extractor"

module Processors
  module LibraryImagesTesseract
    TEMP_IMAGES_DIR = "#{INPUT_FOLDER}/temp".freeze

    def self.process(entries)
      processed = []

      entries.each do |entry|
        extractor = ImageItemExtractor.new(entry[:item], entry[:effects])

        processed.push(extractor.value)
      end

      processed
    end

    def self.make_metadata
      {
        generated: Time.now.to_s,
        script: SCRIPT_URL,
        script_version: SCRIPT_VERSION,
        ruby_version: `ruby -v`.strip,
        tesseract_version: LibraryImagesTesseract.tesseract_version
      }
    end
  end
end
