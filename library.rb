#!/usr/bin/env ruby
# typed: true
require "rubygems"
require "bundler/setup"

require "fileutils"
require "byebug"

SCRIPT_VERSION = "1.0.0"
SCRIPT_URL = "https://github.com/Kisoke/atelier-item-library-tools"

# options parser
require "./utils/options_parser"

# config params
MODES =
  if @command_options[:mix]
    %w[mix]
  elsif @command_options[:mat]
    %w[mat]
  else
    %w[mat mix]
  end.freeze

INPUT_FOLDER = @command_options[:input].freeze
OUTPUT_FOLDER = @command_options[:output].freeze

# Inputs
require "./inputs/library_images_folder"
# Outputs
require "./outputs/array_json_file"
require "./outputs/dictionnary_json_file"

# processors
require "./processors/library_images_tesseract"

OUTPUT_PROCESSORS = [
  Outputs::ArrayJSONFile,
  Outputs::DictionnaryJSONFile
].freeze

def library_extract(folder)
  # remove old tempfiles
  FileUtils.rm_rf(Inputs::LibraryImagesFolder::TEMP_IMAGES_DIR)

  raise "Input directory does not exist" unless Dir.exists?(INPUT_FOLDER)

  Dir.mkdir(Inputs::LibraryImagesFolder::TEMP_IMAGES_DIR)

  input = Inputs::LibraryImagesFolder.new(folder)

  processed = Processors::LibraryImagesTesseract.process(input.entries)

  OUTPUT_PROCESSORS.each do |output|
    output.write_files(
      processed,
      Processors::LibraryImagesTesseract.make_metadata
    )
  end
end

MODES.each { |mode| library_extract mode }
