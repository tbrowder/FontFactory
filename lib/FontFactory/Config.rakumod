unit module FontFactory::Config;

use QueryOS;
use FontFactory::Resources;

my $os = OS.new;

# The subs and data in this file are
# used to construct and use all the required
# data in the $HOME/.FontFactory/
# directory. It also must include code
# to inspect user additions for validity.

=begin comment

=end comment

# The installed GNU Free Fonts fonts are
# contained in different directories:

# Expected directory for installed files
# linux
#   /usr/share/fonts/opentype/freefont/
# macos
#   /opt/homebrew/Caskroom/font-freefont/20120503/freefont-20120503/
# windows
#   /usr/share/fonts/opentype/freefont/


my $Ld = "/usr/share/fonts/opentype/freefont";

my $Md = "/opt/homebrew/Caskroom/font-freefont/20120503/freefont-20120503";

my $Wd = "/usr/share/fonts/opentype/freefont";

my $fntdir;
if $os.is-linux {
    $fntdir = $Ld;
}
elsif $os.is-macos {
    $fntdir = $Md;
}
elsif $os.is-windows {
    $fntdir = $Wd;
}

# Details for the default installed fonts
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
my @fontnames2 =
#   Number is in order listed in
#   The Red Book, Appendix E.1
# integer Full-name  Code  Code2  alias path (path depends on OS)
"1 Free-Serif se t Times ",
"2 Free-Serif-Italic sei ti TimesItalic",
"3 Free-Serif-Bold seb tb TimesBold",
"4 Free-Serif-Bold-Italic sebi tbi TimesBoldItalic",
# Helvetica equivalent (5-8)
"5 Free Sans sa h Helvetica",
"6 Free Sans Oblique sao ho HelveticaOblique",
"7 Free Sans Bold sab hb HelveticaBold",
"8 Free Sans Bold Oblique sabo hbo HelveticaBoldOblique",
# Courier equivalent (9-12)
"9 Free Mono m c Courier",
"10 Free Mono Oblique mo co CourierOblique",
"11 Free Mono Bold mb cb CourierBold",
"12 Free Mono Bold Oblique mbo cbo CourierBoldOblique",
"13 micrenc mi mi none",   # not available in a package
"14 GnuMICR mi2 mi2 none", # not available in a package
"15 CMC7      cm cm none ", #<dir>/$basename"       # not available in a package
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

# create-config :$home, :$debug;
sub create-config(
    :$debug,
    --> Bool
) is export {
    # This is called ONLY if the Config file does NOT exist
    #   along with the files in /resources placed in .FontFactory subdirs
    # the config file is at :
    my $dir  = "{$*HOME}/.FontFactory";
    unless $dir.IO.d {
        mkdir $dir;
    }
    for <docs bin fonts> {
        my $sdir  = "{$*HOME}/.FontFactory/$_";
        unless $sdir.IO.d {
            mkdir $sdir;
        }
    }

    my $cfil = "$dir/Config";

    die "FATAL: Config file exists, take care of business, Tom!" if $cfil.IO.r;

    my %h = get-resources-hash;
    say "DEBUG: downloading /resources";
   
    for %h.kv -> $basename, $rpath {
        say "bnam: '$basename', path: $rpath";
        my $content = slurp-file $rpath, :bin; 
        my $dir = "$*HOME/.FontFactory";
        if $rpath.contains("/docs/") {
            $dir ~= "/docs";
            spurt-file $content, :$dir, :$basename, :bin;
        }
        elsif $rpath.contains("/bin/") {
            $dir ~= "/bin";
            spurt-file $content, :$dir, :$basename, :bin;
        }
        elsif $rpath.contains("/fonts/") {
            $dir ~= "/fonts";
            spurt-file $content, :$dir, :$basename, :bin;
        }
        else {
            die "FATAL: Unknown path '$rpath'";
        }
    }
    say "DEBUG: early exit after creating /resources in .FontFactory";
    #say %h.gist;
    exit;


    die "Tom, take care of Config creation in lib/*/Config";

    # get a file handle
    my $fh = open $cfil, :w;

    =begin comment
    my $nc = 0;
    for 1...15 -> $n {
        my $b = %number{$n}<basename>;
        my $N = $b.chars;
        $nc = $N if $N > $nc;
    }
    # add an ending space for neatness
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
