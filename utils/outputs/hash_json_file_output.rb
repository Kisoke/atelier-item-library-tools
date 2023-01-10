require "./utils/item_hash_converter"

class HashJSONFileOutput
  def self.credits_hash
    {
      generated: Time.now.to_s,
      tesseract_version: tesseract_version,
      script: SCRIPT_URL,
      script_version: SCRIPT_VERSION,
      ruby_version: `ruby -v`.strip
    }
  end

  def self.write_files(extracted_item_structs)
    extracted_item_hashes =
      extracted_item_structs.map { |item| ItemHashConverter.new(item).to_h }

    recipes =
      extracted_item_hashes.to_h { |item| [item[:id], item.delete(:recipe)] }

    File.write(
      "recipes.json",
      { items: recipes, credits: credits_hash }.to_json
    )
    File.write(
      "items.json",
      { items: extracted_item_hashes, credits: credits_hash }.to_json
    )
  end
end
