unit class FreeFont;

use PDF::Font::Loader :load-font;

use FreeFont::Classes;
use FreeFont::Resources;
use FreeFont::Utils;
use FreeFont::X::FontHashes;

# several ways to lookup font faces:
# user enters one of:
#   code or code2 (+ size, default: 12)
#   name (may be fragments), size
#   number, size

# the first two sigs are resolved 
# into the third which is further
# resolved into a DocFont with 
# attributes of:
#   fullname  - complete name, with spaces
#   name      - complete name, without spaces
#   shortname - LC, no spaces -> number:
#   number    - with subkeys for cross-reference

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
has %.fonts; # keep fontinfo by number key

submethod TWEAK {
    %!code      = %FreeFont::X::FontHashes::code;      # code -> number
    %!code2     = %FreeFont::X::FontHashes::code2;     # code2 -> number
    # font names, LC, no spaces -> number:
    %!shortname = %FreeFont::X::FontHashes::shortname;
    %!number    = %FreeFont::X::FontHashes::number;    # 1-13 -> subkeys:
    #note "DEBUG: successful TWEAK and exit"; exit;
}

multi method get-font(
    Str $name, # can be fragments
    Numeric $size!,
    :$debug,
     --> DocFont
) {
    # e.g.: FreeSans, :size(12.5)
    my $fname = $name;
    $fname ~~ s:g/\s+//;  # delete spaces
    $fname ~~ s/\.\w+$//; # delete suffix
    $fname .= lc;

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

    my $o = DocFont.new: :$name, :$size;
    $o
}

multi method get-font($Code, :$debug --> DocFont) {
    my ($num, $name, $size);
    # e.g.: t12d5 OR t12
    my ($code, $code2, $cp1, $cp2, $sizint, $sizfrac);
    with $Code {
        when /^ :i (se|sa|m)  (b|i|o)?  (\d+)    [['d'| '.'] (\d+)]? $/ {
            # Code
            $cp1     = ~$0;
            $cp2     = $1.defined ?? ~$1 !! "";
            $sizint  = +$2;
            $sizfrac = $3.defined ?? +$3 !! "";

            $code    = $cp1 ~ $cp2;
            $size    = "{$sizint}.{$sizfrac}".Numeric;
        }
        when /^ :i (t|h|c)    (b|i|o)? (\d+)     [['d'|'.'] (\d+)]? $/ {
            # Code2
            $cp1     = ~$0;
            $cp2     = $1.defined ?? ~$1 !! "";
            $sizint  = +$2;
            $sizfrac = $3.defined ?? +$3 !! "";

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
        $num  = %!code{$code};
        $name = %!number{$num}<shortname>;
    }
    elsif $code2.defined {
        $num  = %!code2{$code2};
        $name = %!number{$num}<shortname>;
    }

    my $o = DocFont.new: :$name, :$size;
    $o
}

multi method find-font(:$number, :$size, :$debug) {
}

