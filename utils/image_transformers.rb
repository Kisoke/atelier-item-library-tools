require "rmagick"

module ImageTransformers
  class Transform
    def initialize(**kwargs)
      @options = OpenStruct.new(kwargs)
    end
  end

  class Crop < Transform
    def initialize(x: 0, y: 0, width: 10, height: 10)
      super
    end

    def apply(image)
      image.crop(@options.x, @options.y, @options.width, @options.height)
    end
  end

  class Grayscale < Transform
    def initialize(color_bits: 256)
      super
    end

    def apply(image)
      image.quantize(@options.color_bits, Magick::GRAYColorspace)
    end
  end

  class Contrast < Transform
    def initialize(
      black_point: 0,
      white_point: Magick::QuantumRange,
      channel: Magick::DefaultChannels
    )
      super
    end

    def apply(image)
      image.contrast_stretch_channel(
        @options.black_point,
        @options.white_point,
        @options.channel
      )
    end
  end

  class Modulate < Transform
    def initialize(percentage: 50)
      super
    end

    def apply(image)
      image.modulate(@options.percentage / 100.0)
    end
  end

  class Threshold < Transform
    def initialize(threshold: 32_000)
      super
    end

    def apply(image)
      image.threshold(@options.threshold)
    end
  end
end
