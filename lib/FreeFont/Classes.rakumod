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

=head2 Methods

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
=head3 method license
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
    method ascender() { 
        self.face.ascender 
    }
    method descender() { 
    }
    method family-name() { 
    }
    method height() { 
    }
    method leading() {
        self.face.height
    }
    method num-glyphs() { 
    }
    method style-name() {}
    method underline-position() {}
    method underline-thickness() {}

    method overline-position() {}
    method overline-thickness() {}

    method strikethrough-position() {}
    method strikethrough-thickness() {}
    method forall-glyphs() {}

    #= string attrs
    method forall-chars() {}

} # end of class DocFont definition

