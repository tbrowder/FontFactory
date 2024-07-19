unit module FreeFont::Classes;

use FreeFont::X::FontHashes;

my %number = %FreeFont::X::FontHashes::number;

class DocFont is export {
    # these are provided by FreeFont's
    # sub 'get-font'
    has $.number is required;
    has $.size   is required;

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
    has $.file;  # name.otf
    has $.path;  

    #   other attrs
    has $.weight; # Normal, Bold
    has $.slant;  # Italic, Oblique

    =begin comment
    submethod TWEAK {
        # generated in TWEAK using %number
        #   without extension
        $!fullname;  # full name with 
                     # spaces
        $!name;      # full with no 
                     # spaces
        $!shortname; # name.lc

        $!alias; # full Type 1 name
        $!code;
        $!code2;
        #   with file extension
        $!file;  # name.otf
        $!path;  # provided by 
                 # find-font
        #   other attrs
        $!weight;
        $!slant;
    }
    =end comment

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

} # end of class DocFont definition
