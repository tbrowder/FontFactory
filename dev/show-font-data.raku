#!/bin/env raku

use Font::FreeType;
use Font::FreeType::Glyph;

use File::Find;

#use lib "lib";
#use FontInfo;

my @fontdirs = <
/usr/share/fonts/opentype/urw-base35
>;
#/usr/share/fonts/opentype/ebgaramond

for @fontdirs -> $dir {
    my @ffils = find :$dir, :type<file>, :name(/'.otf' $/);
    for @ffils {
        my $filename = $_.Str;
        say "file: $filename";
        my $face = Font::FreeType.new.face($filename);

        say "  Family name: ", $face.family-name;

        say "  Style name: ", $_
              with $face.style-name;
        say "  PostScript name: ", $_
            with $face.postscript-name;
        say "  Number of glyphs: ", $face.num-glyphs;
    }
}

=finish

#!/bin/env raku

use Font::FreeType;
use Font::FreeType::Glyph;

sub MAIN(Str $filename) {
    my $face = Font::FreeType.new.face($filename);

    say "Family name: ", $face.family-name;
    say "Style name: ", $_
        with $face.style-name;
    say "PostScript name: ", $_
        with $face.postscript-name;
    say "Format: ", $_
        with $face.font-format;

    my @properties;

    @properties.push: 'Bold' if $face.is-bold;
    @properties.push: 'Italic' if $face.is-italic;
    say @properties.join: '  ' if @properties;

    @properties = ();
    @properties.push: 'Scalable'    if $face.is-scalable;
    @properties.push: 'Fixed width' if $face.is-fixed-width;
    @properties.push: 'Kerning'     if $face.has-kerning;
    @properties.push: 'Glyph names' ~
                      ($face.has-reliable-glyph-names ?? '' !! ' (unreliable)')
      if $face.has-glyph-names;
    @properties.push: 'SFNT'        if $face.is-sfnt;
    @properties.push: 'Horizontal'  if $face.has-horizontal-metrics;
    @properties.push: 'Vertical'    if $face.has-vertical-metrics;
    with $face.charmap {
        @properties.push: 'enc:' ~ .key.subst(/^FT_ENCODING_/, '').lc
            with .encoding;
    }
    say @properties.join: '  ' if @properties;

    say "Units per em: ", $face.units-per-EM if $face.units-per-EM;
    if $face.is-scalable {
        with $face.bounding-box -> $bb {
            say sprintf('Global BBox: (%d,%d):(%d,%d)',
                        <x-min y-min x-max y-max>.map({ $bb."$_"() }) );
        }
        say "Ascent: ", $face.ascender;
        say "Descent: ", $face.descender;
        say "Text height: ", $face.height;
    }
    say "Number of glyphs: ", $face.num-glyphs;
    say "Number of faces: ", $face.num-faces
      if $face.num-faces > 1;

    if $face.fixed-sizes {
        say "Fixed sizes:";
        for $face.fixed-sizes -> $size {
            say "    ",
            <size width height x-res y-res>\
                .grep({ $size."$_"(:dpi)})\
                .map({ sprintf "$_ %g", $size."$_"(:dpi) })\
                .join: ", ";
        }
    }
}
