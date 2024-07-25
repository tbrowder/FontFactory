#!/bin/env raku

use Font::FreeType;
use Font::FreeType::Glyph;
use Font::FreeType::Outline;
use Font::FreeType::Raw::Defs;

my @fts = <
fonts/CMC7.ttf
fonts/GnuMICR.otf
fonts/micrenc.ttf
>;

my $all   = 0; # if true, show unmapped glyphs
my $debug = 0;
if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <font filename> | 1 | 2 | 3 [all debug]

    Show all mapped glyphs in the input font file or the file number:

    HERE
    my $n = 1;
    for @fts {
        say "  $n - $_";
        ++$n;
    }

    print qq:to/HERE/;

    all - also show unmapped glyphs
    HERE

    exit;
}

#for @*ARGS {
#}

# dump all characters that are mapped to a font
sub list-chars(
    Str $filename, 
    Bool :$mapped = True,
    :$debug) {

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

    if not $mapped {
        # output unmapped glyphs
        $face.forall-chars: :load, :flags(FT_LOAD_NO_RECURSE), 
            -> Font::FreeType::Glyph:D $_ {

            if .index && !@charmap[.index] {
                say join("\t", '[' ~ .index ~ ']', '/' ~ (.name//''), );
            }
        }
    }
}
