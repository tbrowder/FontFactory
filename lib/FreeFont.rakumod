unit class FreeFont;

use PDF::Font::Loader :find-font, :load-font;

use FreeFont::Classes;
use FreeFont::FontHashes;
use FreeFont::Resources;
use FreeFont::Utils;

# several ways to lookup font faces:
# user enters one of:
#   code
#   code2
#   fullname  -  complete name (with spaces)
#   shortname - LC, no spaces -> number:
#   name - complete name, without spaces
#   number    - with subkeys fpr cross-reference

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

submethod TWEAK {
    %!code      = get-code-hash;      # code -> number
    %!code2     = get-code2-hash;     # code2 -> number
    # font names, LC, no spaces -> number:
    %!shortname = get_shortname-hash;
    %!number    = get-number-hash;    # 1-13 -> subkeys:
}

multi method get-font($name, Numeric :$size, :$debug --> DocFont) {
    # e.g.: FreeSans, :size(12.5)
    my $fname = $name;
    $fname ~~ s:g/\s+//;  # delete spaces
    $fname ~~ s/\.\w+$//; # delete suffix
    $fname .= lc;

    note "DEBUG: \$fname = '$fname'";
    with $fname {
        when %!fonts{$fname}:exists {
            ; # ok
        }
        default {
            note "FATAL: You entered the desired font name '$name'.";
            die q:to/HERE/;
            Font name '$name' is not recognized. It must be one of the following:
              {say "  $_" for %!fonts.keys.sort}
            HERE
        }
    }

    my $o = DocFont.new: :$name, :$size;
    $o
}

multi method get-font($code, :$debug --> DocFont) {
    # e.g.: t12d5 OR t12
    my ($cp1, $cp2);
    with $code {
        when /^ :i (se|sa|m)  (b|i|o)?  (\d+)    [['d'| '.'] (\d+)]? $/ {
            # Code
            ; # ok for now
        }
        when /^ :i (t|h|c)    (b|i|o)? (\d+)     [['d'|'.'] (\d+)]? $/ {
            # Code2
            ; # ok for now
        }
        default {
            note "FATAL: You entered the desired font code '$code'.";
            die q:to/HERE/;
            The desired font code entry must be in the format "\<code>\<size>"
            where "\<code>" is a valid font code or and "\<size>"
            is either an integral number or a decimal number in
            the form "\d+d\d+" (e.g., '12d5' which means '12.5' PS points).
            HERE
        }
    }

    my $o = DocFont.new: :$name, :$size;
    $o
}
