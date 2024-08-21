unit module FontFactory::Config;

use Text::Utils :strip-comment;
use QueryOS;

use FontFactory::Resources;
use FontFactory::Roles;

my $os = OS.new;

=begin comment

=end comment

# The subs and data in this file used the data in the
# $HOME/.FontFactory/ directory. It must include code to inspect user
# additions for validity.

# Original etails for the default installed fonts follow. The lines
# are translated into a different format for practical use in the
# using OS iin the FontFactory::BuildUtils module used by the
# installer.

constant @fontnames =
# Full name, code, code2, number, alias
#   Number is in order listed in
#   The Red Book, Appendix E.1
# Times equivalent (1-4)
"Free Serif se t 1 Times",
"Free Serif Italic sei ti 2 TimesItalic",
"Free Serif Bold seb tb 3 TimesBold",
"Free Serif Bold Italic sebi tbi 4 TimesBoldItalic",
# Helvetica equivalent (5-8)
"Free Sans sa h 5 Helvetica",
"Free Sans Oblique sao ho 6 HelveticaOblique",
"Free Sans Bold sab hb 7 HelveticaBold",
"Free Sans Bold Oblique sabo hbo 8 HelveticaBoldOblique",
# Courier equivalent (9-12)
"Free Mono m c 9 Courier",
"Free Mono Oblique mo co 10 CourierOblique",
"Free Mono Bold mb cb 11 CourierBold",
"Free Mono Bold Oblique mbo cbo 12 CourierBoldOblique",
"micrenc mi mi 13 none",   # not available in a package
"GnuMICR mi2 mi2 14 none", # not available in a package
"CMC7 cm cm 15 none"       # not available in a package
;


#== exported subs ==========================
# Called only at FontFactory class instantiation
# in TWEAK. We MUST know system font paths for
# the first 15 fonts for this to work.
# Any fonts numbered > 15 should be okay.
sub extract-config(
    :$home!,
    :$dotFontFactory!,
    :$debug,
    --> Array
    ) is export {
    check-config :$home, :$dotFontFactory, :$debug;
    "$home/$dotFontFactory/Config".IO.lines;
}

#== non-exported subs ===========================
# has-config
sub has-config(
    :$debug,
    --> Bool
    ) {
    my $status = True;
    my $cfil = "$*HOME/.FontFactory/Config";
    unless $cfil.IO.r {
        $status = False;
    }
    $status;
}

# check-config
sub check-config(
    :$debug,
    --> Bool
    ) {
    my $status = True;
    my $cfil = "$*HOME/.FontFactory/Config";

}


=finish

# create-config :$home, :$debug;
sub create-config(
    :$home!,
    :$dotFontFactory!,
    :$debug,
    --> Bool
) {
    # the config file is at :
    my $dir  = "$home/$dotFontFactory";
    unless $dir.IO.d {
        mkdir $dir;
    }
    # return False if the file exists?
    my $cfil = "$dir/Config";
    die "FATAL: Config file exists, take care of business, Tom!" if $cfil.IO.r;
;
    if $ofil.IO.r {
        # get a file handle
    }

    my $fh = open $ofil, :w;

    =begin comment
    my $nc = 0;
    for 1...15 -> $n {
        my $b = %number{$n}<basename>;
        my $N = $b.chars;
        $nc = $N if $N > $nc;
    }
    # add an ennding space for neatness
    ++$nc;

    # create a comment header
    my $t = "# Basename";
    my $T = sprintf("%-*.*s", $nc, $nc, $t);
    $T ~= ": Path";
    $fh.say: $T;

    # take care of the GNU Free Fonts
    for 1...12 -> $n {
        my $b = %number{$n}<basename>;
        my $f = %number{$n}<path>;
        my $s = sprintf("%-*.*s", $nc, $nc, $b);
        $s ~= ": $f";
        $fh.say: $s;
    }

    # the Micre fonts
    for 13...15 -> $n {
        my $b = %number{$n}<basename>;
        # the path is in the user's '$HOME/$dotFontFactory/fonts' directory
        my $f = "$dir/fonts/$b";
        if $debug {
            note "DEBUG: spec fonts are at path: $f";
        }
        my $s = sprintf("%-*.*s", $nc, $nc, $b);
        $s ~= ": $f";
        $fh.say: $s;
    }
    $fh.close;
    =end comment
}
