ITEM_ATTRIBUTES_EXTRACTION_CONFIG = {
  name: {
    transforms: [
      { type: "crop", parameters: { x: 165, y: 130, width: 435, height: 55 } },
      { type: "contrast", parameters: { black_point: 12_000 } },
      "grayscale"
    ]
  },
  level: {
    tesseract_type: :integer,
    transforms: [
      { type: "crop", parameters: { x: 274, y: 249, width: 60, height: 53 } },
      "grayscale"
    ]
  },
  value: {
    tesseract_type: :integer,
    transforms: [
      { type: "crop", parameters: { x: 235, y: 573, width: 162, height: 36 } },
      "grayscale"
    ]
  },
  category0: {
    tesseract_type: :category,
    transforms: [
      { type: "crop", parameters: { x: 303, y: 729, width: 198, height: 34 } },
      { type: "contrast", parameters: { black_point: 0 } },
      "grayscale"
    ]
  },
  category1: {
    tesseract_type: :category,
    transforms: [
      { type: "crop", parameters: { x: 632, y: 729, width: 198, height: 34 } },
      { type: "contrast", parameters: { black_point: 0 } },
      "grayscale"
    ]
  },
  category2: {
    tesseract_type: :category,
    transforms: [
      { type: "crop", parameters: { x: 303, y: 824, width: 198, height: 34 } },
      { type: "contrast", parameters: { black_point: 0 } },
      "grayscale"
    ]
  },
  category3: {
    tesseract_type: :category,
    transforms: [
      { type: "crop", parameters: { x: 632, y: 824, width: 198, height: 34 } },
      { type: "contrast", parameters: { black_point: 0 } },
      "grayscale"
    ]
  }
}.freeze

ITEM_RECIPE_EXTRACTION_CONFIG = {
  material0: {
    transforms: [
      { type: "crop", parameters: { x: 1053, y: 477, width: 274, height: 32 } },
      "grayscale"
    ]
  },
  material1: {
    transforms: [
      { type: "crop", parameters: { x: 1464, y: 477, width: 274, height: 32 } },
      "grayscale"
    ]
  },
  material2: {
    transforms: [
      { type: "crop", parameters: { x: 1053, y: 581, width: 274, height: 32 } },
      "grayscale"
    ]
  },
  material3: {
    transforms: [
      { type: "crop", parameters: { x: 1464, y: 581, width: 274, height: 32 } },
      "grayscale"
    ]
  }
}.freeze

ITEM_EFFECTS_EXTRACTION_CONFIG = {
  effect0: {
    tesseract_type: :effect,
    transforms: [
      { type: "crop", parameters: { x: 414, y: 224, width: 425, height: 207 } },
      "grayscale",
      { type: "threshold", parameters: { threshold: 50_000 } }
    ]
  },
  effect1: {
    tesseract_type: :effect,
    transforms: [
      {
        type: "crop",
        parameters: {
          x: 1048,
          y: 224,
          width: 425,
          height: 207
        }
      },
      "grayscale",
      { type: "threshold", parameters: { threshold: 50_000 } }
    ]
  },
  effect2: {
    tesseract_type: :effect,
    transforms: [
      { type: "crop", parameters: { x: 414, y: 451, width: 425, height: 207 } },
      "grayscale",
      { type: "threshold", parameters: { threshold: 50_000 } }
    ]
  },
  effect3: {
    tesseract_type: :effect,
    transforms: [
      {
        type: "crop",
        parameters: {
          x: 1048,
          y: 451,
          width: 425,
          height: 207
        }
      },
      "grayscale",
      { type: "threshold", parameters: { threshold: 50_000 } }
    ]
  },
  effect0_levels: {
    tesseract_type: :effectlevel,
    transforms: [
      { type: "crop", parameters: { x: 840, y: 224, width: 100, height: 207 } },
      "grayscale",
      { type: "threshold", parameters: { threshold: 50_000 } }
    ]
  },
  effect1_levels: {
    tesseract_type: :effectlevel,
    transforms: [
      { type: "crop", parameters: { x: 840, y: 224, width: 100, height: 207 } },
      "grayscale",
      { type: "threshold", parameters: { threshold: 50_000 } }
    ]
  },
  effect2_levels: {
    tesseract_type: :effectlevel,
    transforms: [
      { type: "crop", parameters: { x: 840, y: 224, width: 100, height: 207 } },
      "grayscale",
      { type: "threshold", parameters: { threshold: 50_000 } }
    ]
  },
  effect3_levels: {
    tesseract_type: :effectlevel,
    transforms: [
      { type: "crop", parameters: { x: 840, y: 224, width: 100, height: 207 } },
      "grayscale",
      { type: "threshold", parameters: { threshold: 50_000 } }
    ]
  }
}.freeze

ITEM_OUTPUT = {
  id: {
    key: "name",
    call: ["parameterize"]
  },
  name: {
    key: "name"
  },
  level: {
    key: "level"
  },
  value: {
    key: "value"
  },
  categories: {
    type: :array,
    count: 4,
    element: {
      id: {
        call: ["parameterize"]
      }
    }
  },
  recipe: {
    type: :object,
    element: {
      items: {
        type: :array
      }
    }
  }
}

COMPLETE_WITH_GAME_DATA = false
