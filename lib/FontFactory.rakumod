unit class FontFactory;

use PDF::Font::Loader :load-font;
use PDF::Content;

use QueryOS;

use FontFactory::FontClasses;
use FontFactory::Resources;
use FontFactory::Utils;
use FontFactory::Config;

=begin comment
  # move to FontClasses:
# Translate the default list to the Config format:
# 1 to 6 fields:  all are used for the default fonts
# 1 to 6 fields:  1, 2, and 6 are mandatory for any user-added fonts
#   and fields 3, 4, and 5 are optional
#   if there are less than 6 fields, then the last must be a valid font path
#   if there are more than 3 fields, the last is the path, and the remainder
#   are taken to be in order Code, Code2, some alternate name
# all values in the first field must be unique integers > 1
#   and greater than 15 for user-added fonts
# all values in the last field must be a valid OpenType or TrueType font path
# all values in fields 2, 3, and 4 must be unique Raku strings (case-sensitive)
#   Number is in order listed in
#   The Red Book, Appendix E.1
# integer Full-name  Code  Code2  alias path (path depends on OS)
class FontClass {
    has UInt $.number is required;     # field 1
    # fullname may have spaces; the
    # default fonts' fullname has
    # hyphens which are removed in TWEAK
    has Str  $.fullname is required;   # field 2
    has Str  $.code = "";              # field 3
    has Str  $.code2 = "";             # field 4
    has Str  $.alias = "";             # field 5
    has IO::Path:D $.path is required; # field 6

    # Derived attributes
    has $.shortname; # lower-case, no spaces, no suffix
    has $.type;      # Open or TrueType
    has $.basename;

    submethod TWEAK {
        if $!number < 16 {
            $!fullname ~~ s:g/'-'/ /;
        }
        $!shortname = $!fullname.lc;
        $!shortname ~~ s:g/'-'/ /;
        $!basename = $!path.IO.basename;
        if $!path ~~ /:i '.' otf $/ {
            $!type = 'OpenType';
        }
        elsif $!path ~~ /:i '.' ttf $/ {
            $!type = 'TrueType';
        }
        else {
            die "FATAL: Unknown font type with basename '$!basename'";
        }
    }
}

role DocRole {
    has UInt $.number;
    has Numeric $.size is required;
}

class DocFont is FontClass {
    has $.face;
}
=end comment


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
has %.number;    # 1-15 -> subkeys:
#   name
#   code
#   code2
#   shortname
#   fullname
#   path
# numbers > 15 are for user-added fonts

#   font object
has PDF::Content::FontObj %.fonts; # keep the loaded FontObj by number key

submethod TWEAK {
    # create the hash of FontClass from the Config file
    my ($home, $dotFontFactory, $debug);
    $home = %*ENV<HOME>;
    if "$home/.FontFactory".IO.d {
        $dotFontFactory = "$home/.FontFactory".IO.d
    }
    else {
        die "Tom, fix this";
    }



    my @f = extract-config :$home, :$dotFontFactory, :$debug; # get-config-array;
    for @f {
        say "DEBUG: $_";
    }
    say "debug exit"; exit;

    for @f.kv -> $i, $fontinfo {
        my $N = $i+1;
        my @fields = $fontinfo.words;
        if $N < 16 {
            # default MUST have 6 fields

        }
        else {
        }

    }

    self!assemble-hashes

    =begin comment
    %!code      = %FontFactory::X::FontHashes::code;      # code -> number
    %!code2     = %FontFactory::X::FontHashes::code2;     # code2 -> number
    # font names, LC, no spaces -> number:
    %!shortname = %FontFactory::X::FontHashes::shortname;
    %!number    = %FontFactory::X::FontHashes::number;    # 1-15 -> subkeys:
    =end comment
    #note "DEBUG: successful TWEAK and exit"; exit;
}

# private methods
method !assemble-hashes {
    # reads the Config file during TWEAK
    # to populate the class hashes
 #my @arr =
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
        my $path = self.fonts{$number}<path>;
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
        my $path = self.number{$number}<path>;
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
        my $path = self.fonts{$number}<path>;
        $font = $fl.load-font: :file($path);
        self.fonts{$number} = $font;
    }

    my $o = DocFont.new: :$number, :$size, :$font;
    $o
}
