module Outputs
  class OutputChannel
    OUTPUT_DIR = ::OUTPUT_FOLDER

    def self.make_metadata
      {
        generated: Time.now.to_s,
        script: SCRIPT_URL,
        script_version: SCRIPT_VERSION,
        ruby_version: `ruby -v`.strip
      }
    end

    def self.create_output_dir
      Dir.mkdir OUTPUT_DIR unless Dir.exists?(OUTPUT_DIR)
    end
  end
end
