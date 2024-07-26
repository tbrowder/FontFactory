
unit module FreeFont::Font::Utils;

use QueryOS;
use YAMLish;

sub hex2dec($hex, :$debug) is export {
    # converts an input hex sring to a decimal number
    my $dec = parse-base $hex, 16;
    $dec;
}

=finish

# to be exported when the new repo is created
sub help is export {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <mode>

    Modes:
      a - all
      p - print PDF of font samples
      d - download example programs
      L - download licenses
      s - show /resources contents
    HERE
    exit
}

sub with-args(@args) is export {
    for @args {
        when /:i a / {
            exec-d;
            exec-p;
            exec-L;
            exec-s;
        }
        when /:i d / {
            exec-d
        }
        when /:i p / {
            exec-p
        }
        when /:i L / {
            exec-L
        }
        when /:i s / {
            exec-s
        }
        default {
            say "ERROR: Unknown arg '$_'";
        }
    }
}

# local subs, non-exported
sub exec-d() {
    say "Downloading example programs...";
}
sub exec-p() {
    say "Downloading a PDF with font samples...";
}
sub exec-L() {
    say "Downloading font licenses...";
}
sub exec-s() {
    say "List of /resources:";
    my %h = get-resources-hash;
    my %m = get-meta-hash;
    my @arr = @(%m<resources>);
    for @arr.sort -> $k {
        say "  $k";
    }

}
