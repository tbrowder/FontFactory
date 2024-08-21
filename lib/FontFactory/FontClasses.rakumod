unit module FontFactory::FontClasses;

use Font::FreeType;
use PDF::Font::Loader :load-font;
use PDF::Content::FontObj;

use FontFactory::Roles;

=begin comment
class FontData is export {
    has UInt     $.number   is required: # field 1
    has Str      $.fullname is required; # field 2
    has Str      $.code;                 # field 3
    has Str      $.code2;                # field 4
    has Str      $.alias;                # field 5
    has IO::Path $.path     is required; # field 6
    
    submethod TWEAK {
        # fonts with $!number < 16 MUST have all 6 attributes defined
        if $!number < 16 {
            my @errs;
            my $err = 0;
            unless $!code.defined  { @errs.push: "undefined .code";  }
            unless $!code2.defined { @errs.push: "undefined .code2"; }
            unless $!alias.defined { @errs.push: "undefined .code2"; }
            my $ne = @errs.elems;
            if @errs {
                my $s = $ne > 1 ?? 's' !! '';
                note "FATAL: Font number $!number has $nd error$s:"; 
                note " $_" for @errs;
                die  "Early ending after fatal error$s.";
            }
        }
    }
}
=end comment

# Translate the default list to the Config format:
# 1 to 6 fields:  all are used for the default fonts
# 1 to 6 fields:  1, 2, and 6 are mandatory for any user-added fonts
#   and fields 3, 4, and 5 are optional
#   if there are less than 6 fields, then the last must be a valid font path
#   if there are more than 3 fields, the last is the path, and the remainder
#   are taken to be in order Code, Code2, some alternate name
# All values in the first field must be unique integers > 1
#   and greater than 15 for user-added fonts
# All values in the last field must be a valid OpenType or TrueType font path
# All values in fields 2, 3, and 4 must be unique Raku strings (case-sensitive)
#   Number is in order listed in
#   The Red Book, Appendix E.1
# integer Full-name  Code  Code2  alias path (path depends on OS)

class FontClass is FontData is export {
#   has UInt $.number is required;     # field 1
    # fullname may have spaces; the
    # default fonts' fullname has
    # hyphens which are removed in TWEAK
#   has Str  $.fullname is required;   # field 2
#   has Str  $.code  = "";             # field 3
#   has Str  $.code2 = "";             # field 4
#   has Str  $.alias = "";             # field 5
#   has IO::Path:D $.path is required; # field 6

    # Derived attributes
    has $.shortname; # lower-case, no spaces, no suffix
    has $.type;      # Open or TrueType
    has $.basename;

    # Loaded at first use
    has PDF::Content::FontObj $.font; 

    submethod TWEAK {
        #if $!number < 16 {
        #   # substitute spaces for '-'
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

=begin pod

=head1 Class DocFont

Class B<DocFont> melds a font file and its scaled size and provides
methods to access most of its attributes.

=head1 Methods

=end pod

class DocFont is export {
    has FontClass $.font is required;
    has $.number is required;
    has $.size is required;
    has $.id;
    submethod TWEAK {
        $!id = "{$!number}|{$!size}";
    }
    # may add methods to expose FontClass attributes, otherwise, just
    # get them by .font.SOME-ATTRIBUTE
}

=begin comment
class DocFont is export {
    # these are provided by FontFactory's
    # sub 'get-font'
    has $.number is required;
    has $.size   is required;
    # the font object from PDF::Font::Loader's load-font :file($path)
    has $.font   is required; #= this is a loaded font, i.e., a FontObj

    # also required now and provided by FontFactory
    has $.fullname is required;  # full name with spaces
    has $.name is required;      # full with no spaces
    has $.shortname is required; # name.lc
    has $.alias is required;     # full Type 1 name
    has $.code is required;
    has $.code2 is required;
    #   with file extension
    has $.basename is required;  # name.suffix
    has $.path is required;

    #   other attrs
    has $.weight is required; # Normal, Bold
    has $.slant is required;  # Italic, Oblique

    # attributes from FreeType
    has $.face;

    submethod TWEAK {

        =begin comment
        my $n = $!number // 1;
        # generated in TWEAK using %number
        #   without extension
        $!fullname  = %number{$n}<fullname>;  # full name with
                                              # spaces
        $!name      = %number{$n}<name>;      # full with no
                                              # spaces
        $!shortname = %number{$n}<shortname>; # name.lc

        $!alias     = %number{$n}<alias>;     # full Type 1 name
        $!code      = %number{$n}<code>;
        $!code2     = %number{$n}<code2>;
        #   with file extension
        $!basename  = %number{$n}<basename>;   # name.otf
        $!path      = %number{$n}<path>;
        #   other attrs
        $!weight    = %number{$n}<weight>;
        $!slant     = %number{$n}<slant>;
        =end comment

        $!face = Font::FreeType.new.face: $!path;
        $!face.set-font-size: $!size;
    }
} # temp end, rest is at bottom
=end comment

=finish

=begin pod
=head2 Overall font attributes

=head3 license

Short name of the font's license
=end pod
    method license() {
        # DocFont attribute
        # based on number
        my $n = $.number;
        my $lic;
        if 0 < $n < 13 {
            # Gnu FontFactory fonts
            $lic = "GNU GPL V3";
        }
        elsif $n == 13 {
            $lic = "FREEWARE";
        }
        elsif $n == 14 {
            $lic = "GNU GPL V2";
        }
        elsif $n == 15 {
            $lic = "";
        }
        else {
            die "FATAL: Unexpected font number $n";
        }

        $lic
    } # end of method def

    # various font and string methods provided by $!face (self.face)

    #= general font attrs
=begin pod
=head3 ascender()

Scaled maximum height above the baseline of all the font's glyphs
=end pod
    method ascender() {
        self.face.ascender
    }

=begin pod
=head3 descender()

Scaled depth below the baseline of all the font's glyphs
(usually negative)
=end pod
    method descender() {
        self.face.descender
    }

=begin pod
=head3 family-name()

The family this font claims to be from
=end pod
    method family-name() {
        self.face.family-name
    }

=begin pod
=head3 height()

Scaled recommended distance between baselines
=end pod
    method height() {
        self.face.height
    }

=begin pod
=head3 leading()

Scaled recommended distance between baselines
(alias for 'height', preferred term for typesetting)
=end pod
    method leading() {
        self.face.height
    }

=begin pod
=head3 has-glyph-names()

True if individual glyphs have names. If so, the
name is shown with the 'name' method on 'Glyph' objects
=end pod
    method has-glyph-names {
        self.face.has-glyph-names
    }

=begin pod
=head3 has-reliable-glyph-names()

True if the font contains reliable PostSript glyph names
=end pod
    method has-reliable-glyph-names {
        self.face.has-reliable-glyph-names
    }

=begin pod
=head3 postscript-name()

=end pod
    method postscript-name() {
        self.face.postscript-name
    }

=begin pod
=head3 is-bold()

=end pod
    method is-bold {
        self.face.is-bold
    }

=begin pod
=head3 is-italic()

=end pod
    method is-italic {
        self.face.is-italic
    }

=begin pod
=head3 is-scalable()

=end pod
    method is-scalable {
        self.face.is-scalable
    }

=begin pod
=head3 num-glyphs()

=end pod
    method num-glyphs() {
        self.face.num-glyphs
    }

=begin pod
=head3 style-name()

=end pod
    method style-name() {
        self.face.style-name
    }

=begin pod
=head3 underline-position()

=end pod
    method underline-position() {
        self.face.underline-position
    }

=begin pod
=head3 underline-thickness()

=end pod
    method underline-thickness() {
        self.face.underline-thickness
    }

=begin pod
=head3 overline-position()

=end pod
    method overline-position() {
        self.face.overline-position()
    }

=begin pod
=head3 overline-thickness()

=end pod
    method overline-thickness() {
        self.face.overlin-thickness
    }

=begin pod
=head3 strikethrough-position()

=end pod
    method strikethrough-position() {
        self.face.strikethrough-position
    }

=begin pod
=head3 strikethrough-thickness()

=end pod
    method strikethrough-thickness() {
        self.face.strikethrough-thickness
    }

    method units-per-EM() {
    }

=begin pod
=head3 forall-glyphs()

Iterates through all the glyphs in the font
and passes Font::FreeType::Glyph objects.
=end pod
    method forall-glyphs() {
        self.face.forall-glyphs: -> {
        }
    }

=begin pod
=head3 method max-advance-width()

=end pod
    method max-advance-width() {
    }

=begin pod
=head3 method max-advance-height()

=end pod
    method max-advance-height() {
        # for vertical languages
    }

=begin pod
=head3 method bbox()

=end pod
    method bbox() {
    }


### char or string methods

=begin pod
=head2 Methods on strings

=head3 forall-chars()

=end pod
    method forall-chars() {
    }

=begin pod
=head3 glyph-name($char)

=end pod
    method glyph-name($char) {
    }

=begin pod
=head3 glyph-index($char)

=end pod
    method glyph-index($char) {
    }

=begin pod
=head3 glyph-name-from-index($index)

=end pod
    method glyph-name-from-index($index) {
    }

=begin pod
=head3 index-from-glyph-name($name)

=end pod
    method index-from-glyph-name($name) {
    }

=begin pod
=head3 set-font-size($width, $height, $x-res, $y-res)

=end pod
    method set-font-size($width, $height, $x-res, $y-res) {
    }

    # derived methods by iteration over glyphs in a string
    # This should be a class instance of a String with all
    # its attributes calculated. But threading may be a
    # problem.
    method string(
        Str:D $text,
        :$kern,
        :$ligatures,
        :$debug,
        --> String
        ) {
        my $s = String.new:
        self.face.for-glyphs: $text, -> Font::FreeType::Glyph $g {
            # based on code from the example in David's Glyph doc
            my $name = $g.name;
            # ... collect all the attrs for the string

        }
        $s
    }

} # end of class DocFont definition
