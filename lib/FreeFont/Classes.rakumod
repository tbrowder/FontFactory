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
}
