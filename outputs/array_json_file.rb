require "./outputs/output_channel"
require "./outputs/item_hash_converter"

module Outputs
  class ArrayJSONFile < OutputChannel
    def self.write_files(extracted_item_structs, **metadata)
      extracted_item_hashes =
        extracted_item_structs.map { |item| ItemHashConverter.new(item).to_h }

      recipes = extracted_item_hashes.map { |item| item.delete(:recipe) }

      metadata = make_metadata.merge(metadata)

      create_output_dir

      File.write(
        "#{OUTPUT_DIR}/recipes_array.json",
        { items: recipes, metadata: metadata }.to_json
      )
      File.write(
        "#{OUTPUT_DIR}/items_array.json",
        { items: extracted_item_hashes, credits: metadata }.to_json
      )
    end
  end
end
