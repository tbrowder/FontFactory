unit class FreeFont;

use PDF::Font::Loader :find-font, :load-font;

# several ways to lookup font faces:
# user enters one of:
#   code
#   code2
#   complete name
# number
# name (various)
# code (see table)
# code2 (see table)
has %.code;      # code -> number
has %.code2;     # code2 -> number
# font names, LC, no spaces -> number:
has %.shortname;
has %.number; # 1-13 -> subkeys:
              # code, code2, shortname
              # name, fullname, path,
              # font object

my @fontnames =
# full name, code, code2
# Courier equivalent
"Free Mono m c",
"Free Mono Bold mb cb",
"Free Mono Bold Oblique mbo cbo",
"Free Mono Oblique mo co",
# Helvetica equivalent
"Free Sans sa h",
"Free Sans Bold sab hb",
"Free Sans Bold Oblique sabo hbo",
"Free Sans Oblique sao ho",
# Times equivalent
"Free Serif se t",
"Free Serif Bold seb tb",
"Free Serif Bold Italic sebi tbi",
"Free Serif Italic sei ti",
;

class DocFont {
    has $.size;
    has $.fullname;  # full name with spaces
    has $.name;      # full with no spaces
    has $.shortname; # name.lc

    has $.file;  # name.otf
    has $.alias; # full Type 1 name
    has $.code;
    has $.code2;
    has $.path;

    submethod TWEAK {
    }
}

submethod TWEAK {
    for @fontnames.kv -> $i, $v is copy {
        my $n = $i + 1; # for user
        # the last two words are 'code'
        #   and 'code2', respectively
        my @w = $v.words;
        my $code2 = @w.unshift;
        my $code  = @w.unshift;
        # reassemble
        $v = @w.join(" ");
        my $full-name  = $v;
        my $name       = $v;
        my $short-name = $v;
        # delete spaces
        $short-name ~~ s:g/\s+//; 
        $short-name .= lc;
        my $f = $v.lc;
        #%!fonts{$short-name} = $v;
    }
}

=begin comment
all font files in dir /usr/share/fonts/opentype/freefont
FreeMono.otf
FreeMonoBold.otf
FreeMonoBoldOblique.otf
FreeMonoOblique.otf
FreeSans.otf
FreeSansBold.otf
FreeSansBoldOblique.otf
FreeSansOblique.otf
FreeSerif.otf
FreeSerifBold.otf
FreeSerifBoldItalic.otf
FreeSerifItalic.otf
=end comment

multi method get-font($name, Numeric :$size, :$debug --> Font) {
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

    my $o = Font.new: :$name, :$size;
    $o
}

multi method get-font($code, :$debug --> Font) {
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

}
