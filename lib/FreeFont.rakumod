unit class FreeFont;

use PDF::Font::Loader :load-font;
use PDF::Content;

use QueryOS;

use FreeFont::Classes;
use FreeFont::Resources;
use FreeFont::Utils;
use FreeFont::X::FontHashes;

%number = %FreeFont::X::FontHashes::number;

# Several ways to lookup font faces:
# User enters one of:
#   code or code2 (+ size, default: 12)
#   name (may be fragments), size
#   number, size

# The first two signatures are resolved
# into the third which is further
# resolved into a DocFont with
# attributes of:
#   fullname  - complete name, with spaces
#   name      - complete name, without spaces
#   shortname - LC, no spaces -> number:
#   number    - with subkeys for cross-reference
#   license info


# name (various)
# code (see table)
# code2 (see table)
has %.code;      # code -> number
has %.code2;     # code2 -> number
# font shortname, LC, no spaces -> number:
has %.shortname;
has %.number; # 1-13 -> subkeys:

#   code
#   code2
#   shortname
#   name
#   fullname
#   path
#   font object
has PDF::Content::FontObj %.fonts; # keep the loaded FontObj by number key

submethod TWEAK {
    %!code      = %FreeFont::X::FontHashes::code;      # code -> number
    %!code2     = %FreeFont::X::FontHashes::code2;     # code2 -> number
    # font names, LC, no spaces -> number:
    %!shortname = %FreeFont::X::FontHashes::shortname;
    %!number    = %FreeFont::X::FontHashes::number;    # 1-15 -> subkeys:
    #note "DEBUG: successful TWEAK and exit"; exit;
}

multi method get-font(
    UInt $number where { 0 < $_ < 16 },
    Numeric $size = 12,
    :$debug,
    --> DocFont
) {
    # load the font
    my PDF::Font::Loader $fl .= new;
    my $font;
    if self.fonts{$number}:exists {
        $font = self.fonts{$number};
    }
    else {
        my $path = %number{$number}<path>;
        $font = $fl.load-font: :file($path);
        %!fonts{$number} = $font;
    }

    my $o = DocFont.new: :$number, :$size, :$font;
    $o
}

multi method get-font(
    Str :$find!, # can be fragments
    Numeric :$size = 12,
    :$debug,
    --> DocFont
) {
    # e.g.: :find<FreeSans>; # default size: 12
    #   OR
    #     : :find<FreeSans>, :size(12.5)

    my $s = $find.lc;
    my @w = $s.words;

    # set defaults as last resort
    my ($name = "FreeSerif", $weight = "", $slant = "", $number = 1);

    =begin comment
    note "DEBUG: \$fname = '$fname'" if $debug;
    with $fname {
        when %!shortname{$fname}:exists {
            ; # ok
        }
        default {
            note "FATAL: You entered the desired font name '$name'.";
            note qq:to/HERE/;
            Font name '$name' is not recognized. It must be one of the following:
              {say "  $_" for %!fonts.keys.sort}
            HERE
            exit;
        }
    }
    =end comment

    # load the font
    my PDF::Font::Loader $fl .= new;
    my $font;
    if self.fonts{$number}:exists {
        $font = self.fonts{$number};
    }
    else {
        my $path = %number{$number}<path>;
        $font = $fl.load-font: :file($path);
        self.fonts{$number} = $font;
    }

    my $o = DocFont.new: :$number, :$size, :$font;
    $o
}

multi method get-font(
    Str $Code,
    :$debug,
    --> DocFont
) {
    my ($number, $size);
    # e.g.: 't12d5' OR 't12' OR 't' 
    my ($code, $code2, $cp1, $cp2, $sizint, $sizfrac);
    with $Code {
        when /^ :i (se|sa|m)  (b|i|o)?  (\d+)?    [['d'| '.'] (\d+)]? $/ {
            # Code
            $cp1     = ~$0;
            $cp2     = $1.defined ?? ~$1 !! "";
            $sizint  = $2.defined ?? +$2 !! 12;
            $sizfrac = $3.defined ?? +$3 !! 0;

            $code    = $cp1 ~ $cp2;
            $size    = "{$sizint}.{$sizfrac}".Numeric;
        }
        when /^ :i (t|h|c)    (b|i|o)? (\d+)?     [['d'|'.'] (\d+)]? $/ {
            # Code2
            $cp1     = ~$0;
            $cp2     = $1.defined ?? ~$1 !! "";
            $sizint  = $2.defined ?? +$2 !! 12;
            $sizfrac = $3.defined ?? +$3 !! 0;

            $code2   = $cp1 ~ $cp2;
            $size    = "{$sizint}.{$sizfrac}".Numeric;
        }
        default {
            note "FATAL: You entered the desired font code '$code'.";
            note q:to/HERE/;
            The desired font code entry must be in the format "\<code>\<size>"
            where "\<code>" is a valid font code and "\<size>"
            is either an integral number or a decimal number in
            the form "\d+d\d+" (e.g., '12d5' which means '12.5' PS points).
            HERE
            exit;
        }
    }

    if $code.defined {
        $number = %!code{$code};
    }
    elsif $code2.defined {
        $number = %!code2{$code2};
    }

    # load the font
    my PDF::Font::Loader $fl .= new;
    my $font;
    if self.fonts{$number}:exists {
        $font = self.fonts{$number};
    }
    else {
        my $path = %number{$number}<path>;
        $font = $fl.load-font: :file($path);
        self.fonts{$number} = $font;
    }

    my $o = DocFont.new: :$number, :$size, :$font;
    $o
}
