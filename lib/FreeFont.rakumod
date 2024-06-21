unit class FreeFont;

has %.codes; # key: font code (see table)
has %.fonts; # font names, LC;

my @fontnames =
"Free Mono",
"Free Mono Bold",
"Free Mono Bold Oblique",
"Free Mono Oblique",
"Free Sans",
"Free Sans Bold",
"Free Sans Bold Oblique",
"Free Sans Oblique",
"Free Serif",
"Free Serif Bold",
"Free Serif Bold Italic",
"Free Serif Italic",
;

class Font {
    has $.size;
    has $.fullname;  # full name
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
    for @fontnames {
        my $full-name  = $_;
        my $name = $_;
        my $short-name = $_;
        $short-name ~~ s:g/\s+//;  # delete spaces
        $short-name .= lc;
        my $f = $_.lc;
        %!fonts{$short-name} = $_;
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
            The desired font code entry must be in the format "<code><size>"
            where "<code>" is a valid font code or and "<size>"
            is either an integral number or a decimal number in
            the form "\d+d\d+" (e.g., '12d5' which means '12.5' PS points).
            HERE
        }
    }

}
