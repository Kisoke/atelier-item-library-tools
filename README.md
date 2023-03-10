# Atelier Item Library Tools

A ruby script using
[tesseract](https://github.com/tesseract-ocr/tesseract)
to extract item information from Atelier games, from
[Gust](https://www.koeitecmoeurope.com/teams/gust/)
.

Utilities
=========

* `library.rb` : Extracts data from in-game library screenshots.
* `export.rb` : Extracts data from game XML data files. NOTE: unfinished.

library.rb
---

Extracts data from in-game library screenshots.

Requires `config/library_images_tesseract_config.rb` to exist and define constants like in `config_examples/a23_library_images_tesseract_config_example.rb`.

Config hashes keys should not change, but the values for their transforms, particularly `crop` bounding rectangles, which should be changed to match your game, and screenshot resolution.

The sample config file works out of the box with Atelier 23 (Sophie 2) with 1080p resolution.

You can play around with transforms param values and look in the `temp` folder to see the cropped pictures which are sent to tesseract for OCR.

Ideal cropped pictures are as follows :
- Binary (black & white) only
- No details aside from text (no background, motifs, cursors...)

If you need to change the structure of the data (output a XML instead of a JSON file), you can write your own output processor, and use it in `library.rb`.

Script is untested against other Atelier games, but should work fine as long as items & library pages follow these rules :
- 4 effects max per item
- 4 innate categories max per item (innate as in, not dependent from a synthesis recipe)
- 4 materials max per item
- Library page has name, level, value, categories, materials (for synthesised items)
- Library pages for synthesised items have an effects page

xmldata.rb
---

Extracts data from game XML files. Unfinished. Do not use this.

Licence
=======

[GPLv3](https://www.gnu.org/licenses/gpl-3.0.html)

Disclaimers
===========

Issues related to tesseract are out of the scope of this script and will be ignored.
