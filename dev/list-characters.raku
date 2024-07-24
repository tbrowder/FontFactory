#!/bin/env raku

use Font::FreeType;
use Font::FreeType::Glyph;
use Font::FreeType::Outline;
use Font::FreeType::Raw::Defs;

# dump all characters that are mapped to a font
sub MAIN(Str $filename, Bool :$mapped = True) {
    my $face = Font::FreeType.new.face($filename);

    my @charmap;
    $face.forall-chars: :!load, :flags(FT_LOAD_NO_RECURSE), 
        -> Font::FreeType::Glyph:D $_ {

        my $bbox = $_.is-outline ?? $_.outline.bbox !! False;
        if $bbox {
            say "    has bbox==== [$bbox]";
        }

        my $char = .char-code.chr;
        @charmap[.index] = $char;
        if $mapped {
            say join("\t", 'x' ~ .char-code.base(16) ~ '[' ~ .index ~ ']',
                     '/' ~ (.name//''),
                     $char.uniname,
                     $char.raku);
        }
    }

    unless $mapped {
        # output unmappd glyphs
        $face.forall-chars: :load, :flags(FT_LOAD_NO_RECURSE), 
            -> Font::FreeType::Glyph:D $_ {

            if .index && !@charmap[.index] {
                say join("\t", '[' ~ .index ~ ']', '/' ~ (.name//''), );
            }
        }
    }
}
