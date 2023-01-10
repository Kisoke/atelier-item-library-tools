#!/usr/bin/env ruby
# typed: true
require "rubygems"
require "bundler/setup"

require "fileutils"

require "byebug"

# Inputs
require "./inputs/library_images_folder"
# Outputs
require "./outputs/array_json_file"
require "./outputs/dictionnary_json_file"

# processors
require "./processors/library_images_tesseract"

SCRIPT_VERSION = "0.1.0"
SCRIPT_URL = "https://github.com/Kisoke/atelier-item-library-tools"

OUTPUT_PROCESSORS = [
  Outputs::ArrayJSONFile,
  Outputs::DictionnaryJSONFile
].freeze

def library_extract
  # remove old tempfiles
  FileUtils.rm_rf(Inputs::LibraryImagesFolder::TEMP_IMAGES_DIR)
  Dir.mkdir(Inputs::LibraryImagesFolder::TEMP_IMAGES_DIR)

  input = Inputs::LibraryImagesFolder.new("mix")

  processed = Processors::LibraryImagesTesseract.process(input.entries)

  OUTPUT_PROCESSORS.each do |output|
    output.write_files(
      processed,
      Processors::LibraryImagesTesseract.make_metadata
    )
  end
end

library_extract
