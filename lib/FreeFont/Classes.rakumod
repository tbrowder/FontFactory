unit module FreeFont::Classes;

use Font::FreeType;
use PDF::Font::Loader :load-font;
use PDF::Content::FontObj;

use FreeFont::X::FontHashes;

%number = %FreeFont::X::FontHashes::number;

=begin pod

=head1 Class DocFont

Class B<DocFont> melds a font file and its scaled size and provides
methods to access most of its attributes.

=head1 Methods

=end pod

class DocFont is export {
    # these are provided by FreeFont's
    # sub 'get-font'
    has $.number is required;
    has $.size   is required;
    # the font object from PDF::Font::Loader's load-font :file($path)
    has $.font   is required; #= this is a loaded font, i.e., a FontObj

    # remainder are generated in TWEAK
    #   without extension
    has $.fullname;  # full name with 
                     # spaces
    has $.name;      # full with no 
                     # spaces
    has $.shortname; # name.lc

    has $.alias; # full Type 1 name
    has $.code;
    has $.code2;
    #   with file extension
    has $.basename;  # name.suffix
    has $.path;  

    #   other attrs
    has $.weight; # Normal, Bold
    has $.slant;  # Italic, Oblique

    # attributes from FreeType
    has $.face;

    submethod TWEAK {

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

        $!face = Font::FreeType.new.face: $!path;
        $!face.set-font-size: $!size;
    }

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
            # Gnu FreeFont fonts
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
    }

=begin pod
=head3 has-reliable-glyph-names()

True if the font contains reliable PostSript glyph names
=end pod
    method has-reliable-glyph-names {
    }

=begin pod
=head3 is-bold()

=end pod
    method is-bold {
    }

=begin pod
=head3 is-italic()

=end pod
    method is-italic {
    }

=begin pod
=head3 is-scalable()

=end pod
    method is-scalable {
    }

=begin pod
=head3 num-glyphs() 

=end pod
    method num-glyphs() { 
    }

=begin pod
=head3 style-name()

=end pod
    method style-name() {
    }

=begin pod
=head3 underline-position()

=end pod
    method underline-position() {
    }

=begin pod
=head3 underline-thickness()

=end pod
    method underline-thickness() {
    }

=begin pod
=head3 overline-position()

=end pod
    method overline-position() {
    }

=begin pod
=head3 overline-thickness()

=end pod
    method overline-thickness() {
    }

=begin pod
=head3 strikethrough-position()

=end pod
    method strikethrough-position() {
    }

=begin pod
=head3 strikethrough-thickness()

=end pod
    method strikethrough-thickness() {
    }

### glyph or string methods

=begin pod
=head3 forall-glyphs()

=end pod
    method forall-glyphs() {
    }

    #= string attrs
=begin pod
=head3 forall-chars()

=end pod
    method forall-chars() {
    }

} # end of class DocFont definition

