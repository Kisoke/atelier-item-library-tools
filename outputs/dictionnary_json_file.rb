require "./outputs/output_channel"
require "./outputs/item_hash_converter"

module Outputs
  class DictionnaryJSONFile < OutputChannel
    def self.write_files(extracted_item_structs, **metadata)
      extracted_item_hashes =
        extracted_item_structs.map { |item| ItemHashConverter.new(item).to_h }

      recipes =
        extracted_item_hashes.to_h { |item| [item[:id], item.delete(:recipe)] }

      items = extracted_item_hashes.to_h { |item| [item[:id], item] }

      metadata = make_metadata.merge(metadata)

      File.write(
        "#{OUTPUT_DIR}/recipes_dict.json",
        { items: recipes, credits: metadata }.to_json
      )
      File.write(
        "#{OUTPUT_DIR}/items_dict.json",
        { items: items, credits: metadata }.to_json
      )
    end
  end
end
