require "rtesseract"
require "securerandom"
require "pathname"

CHAR_BLACKLIST = "|=!/\\[]©@®" # those will never be in the game's library pages

PATTERNS_PARENT = SecureRandom.uuid.freeze

def write_pattern(pattern, pattern_id)
  path = Pathname.new("/tmp/a23_extractor-#{PATTERNS_PARENT}-#{pattern_id}.txt")
  File.write(path, pattern + "\n")

  path
end

class ImageTextExtractor
  def initialize(image_path, **kwargs)
    @image_path = image_path
    @options = OpenStruct.new kwargs

    if @options.tessedit_char_blacklist
      @options.tessedit_char_blacklist += CHAR_BLACKLIST
    else
      @options.tessedit_char_blacklist = CHAR_BLACKLIST
    end
  end

  def extract
    @extracted ||= RTesseract.new(@image_path.to_s, **@options.to_h)
  end

  def extract!
    RTesseract.new(@image_path.to_s, **@options.to_h)
  end

  def value
    extract unless @extracted

    @value ||= @extracted.to_s.strip
  end
end

class ImageStringExtractor < ImageTextExtractor
  def initialize(image_path)
    super(image_path, psm: 7, oem: 1, lang: :eng)
  end

  def value
    super

    @value = @value.parameterize
  end
end

class ImageIntegerExtractor < ImageTextExtractor
  def initialize(image_path)
    super(image_path, config_file: :digits, psm: 7, oem: 1, lang: :eng)
  end

  def value
    super

    @value = @value.to_i
  end
end

class ImageCategoryExtractor < ImageTextExtractor
  CATEGORIES_PATTERN = "(\a\*)"

  def initialize(image_path)
    @categories_pattern_path = write_pattern(CATEGORIES_PATTERN, "categories")

    super(
      image_path,
      user_patterns: @categories_pattern_path.to_s,
      psm: 7,
      oem: 1,
      lang: :eng
    )
  end

  def value
    super

    return @value = nil if @value.size < 5

    @value = @value.parameterize

    @value
  end
end

class ImageEffectExtractor < ImageTextExtractor
  def initialize(image_path)
    super(image_path, psm: 4, oem: 1, lang: :eng)
  end

  def value
    super

    byebug if @value.empty?

    @value.split("\n").filter(&:present?)
  end
end

class ImageEffectLevelExtractor < ImageTextExtractor
  LEVELS_PATTERN = "Lv.\d\*"

  def initialize(image_path)
    @levels_pattern_path = write_pattern(LEVELS_PATTERN, "levels")

    super(
      image_path,
      user_patterns: @levels_pattern_path,
      psm: 6,
      oem: 1,
      lang: :eng
    )
  end

  def value
    super

    byebug if @value.empty?

    @value.split("\n").filter(&:present?)
  end
end
