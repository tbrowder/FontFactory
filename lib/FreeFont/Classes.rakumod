unit module FreeFont::Classes;

class DocFont is export {
    # these are provided by FreeFont's
    # sub 'find-font'
    has $.number is required;
    has $.size   is required;

    # remainder are generated in TWEAK
    has $.fullname;  # full name with 
                     # spaces
    has $.name;      # full with no 
                     # spaces
    has $.shortname; # name.lc

    has $.file;  # name.otf
    has $.alias; # full Type 1 name
    has $.code;
    has $.code2;
    has $.path;  # provided by 
                 # find-font

    has $.weight;
    has $.slant;

    submethod TWEAK {
    }

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
