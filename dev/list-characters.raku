#!/bin/env raku

use Font::FreeType;
use Font::FreeType::Glyph;
use Font::FreeType::Outline;
use Font::FreeType::Raw::Defs;

my @fonts = <
fonts/GnuMICR.otf
fonts/micrenc.ttf
fonts/CMC7.ttf
>;

my $mapped = True;
my $all   = 0; # if true, show unmapped glyphs
my $debug = 0;
my $fnam; # the input font filename
if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <font filename> | 1 | 2 | 3 [all debug]

    Show all mapped glyphs in the input font file or the file number:

    HERE
    my $n = 1;
    for @fonts {
        say "  $n - $_";
        ++$n;
    }

    print qq:to/HERE/;

    all - also show unmapped glyphs
    HERE

    exit;
}

for @*ARGS {
    when /1|2|3/ {
        $fnam = @fonts[$_-1];
    }
    when /^:i d $/ {
        ++$debug;
    }
    when /^:i a $/ {
        ++$all;
        $mapped = False;
    }
    default {
        $fnam = $_;
    }
}

list-chars $fnam, :$mapped;

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
                $char.raku
            );
        }
    }

    if not $mapped {
        # output unmapped glyphs
        $face.forall-chars: :load, :flags(FT_LOAD_NO_RECURSE), 
            -> Font::FreeType::Glyph:D $_ {

            if .index && !@charmap[.index] {
                say join("\t", '[' ~ .index ~ ']', '/' ~ (.name//''), 
                    .raku
                );
            }
        }
    }
}
