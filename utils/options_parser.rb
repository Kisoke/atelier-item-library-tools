require "slop"

@command_options =
  Slop.parse do |o|
    o.string "-i",
             "--input",
             "input directory (default: library)",
             default: "library"
    o.separator "        Input folder must include either a mat or a mix folder, depending on mode."
    o.separator "        Those folders will contain your in-game item library screenshots."
    o.separator "        They are used for material and synthesised items respectively."
    o.separator "        Every even picture in 'mix' folder must be the item effects page."
    o.string "-o", "--output", "output directory (default: out)", default: "out"
    o.separator ""
    o.separator "item processing options:"
    o.bool "--mat", "process only material items"
    o.bool "--mix", "process only synthesised items. takes priority over --mat"
    o.separator ""
    o.separator "other options:"
    o.on "--version", "print script version" do
      puts SCRIPT_VERSION

      exit
    end
    o.on "--help", "print this help message" do
      puts o.to_s

      exit
    end
  end
