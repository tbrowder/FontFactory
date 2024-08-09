Class String
============

Class **String** provides all the scaled size metrics for a string set with a given font at a given size:

    class String is export {

Class DocFont
=============

Class **DocFont** melds a font file and its scaled size and provides methods to access most of its attributes.

Methods
=======

Overall font attributes 
------------------------

### license

Short name of the font's license

### ascender()

Scaled maximum height above the baseline of all the font's glyphs

### descender()

Scaled depth below the baseline of all the font's glyphs (usually negative)

### family-name()

The family this font claims to be from

### height()

Scaled recommended distance between baselines

### leading()

Scaled recommended distance between baselines (alias for 'height', preferred term for typesetting)

### has-glyph-names()

True if individual glyphs have names. If so, the name is shown with the 'name' method on 'Glyph' objects

### has-reliable-glyph-names()

True if the font contains reliable PostSript glyph names

### postscript-name()

### is-bold()

### is-italic()

### is-scalable()

### num-glyphs() 

### style-name()

### underline-position()

### underline-thickness()

### overline-position()

### overline-thickness()

### strikethrough-position()

### strikethrough-thickness()

### forall-glyphs()

Iterates through all the glyphs in the font and passes Font::FreeType::Glyph objects.

### method max-advance-width() 

### method max-advance-height() 

### method bbox() 

Methods on strings
------------------

### forall-chars()

### glyph-name($char)

### glyph-index($char)

### glyph-name-from-index($index)

### index-from-glyph-name($name)

### set-font-size($width, $height, $x-res, $y-res)

