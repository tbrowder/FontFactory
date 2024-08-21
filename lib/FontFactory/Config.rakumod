unit module FontFactory::Config;

use Text::Utils :strip-comment;
use QueryOS;

use FontFactory::Resources;
use FontFactory::Roles;

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

my $fontsdir;
if $os.is-linux {
    $fontsdir = $Ld;
}
elsif $os.is-macos {
    $fontsdir = $Md;
}
elsif $os.is-windows {
    $fontsdir = $Wd;
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
#==================================
my @fontnames2 =
#   Number is in order listed in
#   The Red Book, Appendix E.1
#    1       2        3     4       5    6
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
"13 micrenc mi mi none",    # not available in a package
"14 GnuMICR mi2 mi2 none",  # not available in a package
"15 CMC7      cm cm none ", # not available in a package
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

#| This sub is called only at installation and ONLY 
#|   if the '$*HOME/.FontFactory/Config' file does NOT exist.
#|   Otherwise, any checks of the file or its parent directory
#|   are only checked at class FontFactory instantiation.
#|
#| Sequence of events upon call:
#|   1. The files in the /resources directory are placed into
#|      their correct subdirectories under the 
#|      '$*HOME/.FontFactory' directory.
#|   2. The 'Config' file is created with the correct paths
#|      for the default fonts and the current operating system (OS)
sub create-config(
    :$test-dir, #= for testing locally in the xt dir
    :$debug,
    --> Bool
) is export {
    my ($cdir, $home, $dotFontFactory);
    if $test-dir.IO.d {
        $home = $test-dir;;
    }
    else {
        $home = $*HOME;
    }
 
    $dotFontFactory = ".FontFactory";

    $cdir = "$home/$dotFontFactory";
    unless $cdir.IO.d {
        mkdir $cdir;
    }
    for <docs bin fonts> {
        my $sdir  = "$cdir/$_";
        unless $sdir.IO.d {
            mkdir $sdir;
        }
    }

    my $cfil = "$cdir/Config";

    die "FATAL: Config file exists, take care of business, Tom!" if $cfil.IO.r;

    my %h = get-resources-hash;
    say "DEBUG: downloading /resources" if $debug;
   
    for %h.kv -> $basename, $rpath {
        say "bnam: '$basename', path: $rpath" if $debug;
        my $content = slurp-file $rpath, :bin; 
        my $dir = $cdir;
        if $rpath.contains("/docs/") {
            $dir ~= "/docs";
            if "$dir/$basename".IO.r {
                next if not $debug;
            }
            spurt-file $content, :$dir, :$basename, :bin;
        }
        elsif $rpath.contains("/bin/") {
            $dir ~= "/bin";
            if "$dir/$basename".IO.r {
                next if not $debug;
            }
            spurt-file $content, :$dir, :$basename, :bin;
        }
        elsif $rpath.contains("/fonts/") {
            $dir ~= "/fonts";
            if "$dir/$basename".IO.r {
                next if not $debug;
            }
            spurt-file $content, :$dir, :$basename, :bin;
        }
        else {
            die "FATAL: Unknown path '$rpath'";
        }
    }

    if $debug {
        say "DEBUG: early exit after creating /resources in .FontFactory";
        #say %h.gist;
        exit;
    }

    die "Tom, take care of Config creation in lib/*/Config" if 0;

    # To create the virgin Config file:
    # + read @fontnames2 array: 5 fields per font
    # add correct $fontsdir/$basename for the OS
    # write the info to the Config file

    # get a file handle
    my $fh = open $cfil, :w;
    $fh.print: q:to/HERE/; #: "# See the README for more details.";
    # This file contains font data for the 15 default fonts in this
    # package. Any user-entered fonts MUST be numbered with unique
    # integers > 15 and MUST have unique entries for fields 1, 2, and 6.
    # Note each line's fields are space-separated.
    # Note "fullname" may have hyphens representing spaces.
    #   1       2      3    4      5    6
    # Number Fullname Code Code2 Alias Path
    HERE

    # get the data
    my $N = 0;
    for @fontnames2.kv -> $i, $line is copy {
        $line = strip-comment $line;
        next unless $line ~~ /\S/;
       
        $N += 1;
        my @w = $line.words;
        my $nf = @w.elems;
        die "FATAL: Font data line should have 5 fields but has $nf" if $nf !== 5; 

        my $number   = @w.shift;
        die "FATAL: Font data line number $N should be font number $number"
            if $N !== $nf;

        my $fullname = @w.shift;
        my $code     = @w.shift;
        my $code2    = @w.shift;
        my $alias    = @w.shift;

        # The input fullname may have hyphens representing spaces
        # but retain them for the Config file

        # Create the basename from 'fullname' (which may have hyphens)
        my $basename = $fullname;
        $basename ~~ s:g/'-'//;

        # All default fonts are OpenType except:
        #   micrenc.ttf
        #   CMC7.ttf
        if ($basename ~~ /micrenc/) or ($basename ~~ /CMC7/) {
            $basename ~= '.ttf';
        }
        else {
            $basename ~= '.otf';
        }
        # Finally, get the real source directory
        my $path = "$fontsdir/$basename";

        #==============================
        # IMPORTANT THIS DATA MUST BE ABLE TO ROUNDTRIP WITH 
        # role FontData
        #   see file lib/FontFactory/Roles.rakumod
        #   see test in xt/0-class-
        #==============================
        my $fc = FontData.new: :$number, :$fullname, :$code, :$code2, :$alias, 
                               :$path; 
    }

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
