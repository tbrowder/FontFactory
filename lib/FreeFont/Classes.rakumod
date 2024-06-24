unit module FreeFont::Classes;

class DocFont is export {
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
