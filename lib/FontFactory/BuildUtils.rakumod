unit module FontFactory::BuildUtils;

use PDF::Font::Loader :load-font;
use Text::Utils :split-line;
use YAMLish;
use QueryOS;

#use FontFactory::X::FontHashes;
use FontFactory::Utils;
use FontFactory::Config;
use FontFactory::Resources;

my $os = OS.new;

# The subs and data in this file are
# used to construct and use all the required
# data in the $HOME/.FontFactory/
# directory. It also must include code
# to inspect user additions for validity.

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

# Translate the original default fonts list to the Config format for
# the using OS:

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

# these below may be obsolete OR used in an update
sub find-freefont(
    $number,
    :$debug,
) is export {
    # return path to the file
    # use the font basename
    my ($path, $nam);

    =begin comment
    my %number = get-fonts-hash;
    #$nam = %FontFactory::X::FontHashes::number{$number}<name>;
    $nam = %number{$number}<name>;
    # we need to add '.otf' or '.ttf'
    # to get the basename
    if $nam.starts-with("M") {
        # special case for this one,
        # basename is a bit different
        $nam = "micrenc.ttf";
    }
    else {
        # the GNU fonts just need proper
        # suffix
        $nam ~= ".otf";
    }

    # If the Config file exists, it
    # should already have the 15 paths
    # without using sub locate-font.

    my $config = "%*ENV<HOME>/$dotFontFactory/Config";
    if $config.IO.r {
        # read yml
        my $str  = $config.IO.slurp;
        my %conf = load-yaml $str;
        $path    = %conf{$nam};
    }
    else {
        # Make the query to sub
        # locate-font
        # in module FontFactory::Utils
        $path = locate-font $nam;
    }
    =end comment

    $path
} # sub find-freefont(

=begin comment
sub manage-home-freefont(
    :$home!,
    :$dotFontFactory!,
    :$debug,
    --> Bool
) is export {
    # path to the directory
    # for the config.yml file
    my $dir = "$home/$dotFontFactory";
    unless $dir.IO.d {
        mkdir $dir or return False;
    }

    my $res = False;

    #   We create three other
    #     subdirectories:
    #       .FontFactory/fonts
    #       .FontFactory/docs
    #       .FontFactory/bin
    my $fdir = "$home/$dotFontFactory/fonts";
    mkdir $fdir;
    if not $fdir.IO.d {
        note "ERROR: unable to create dir '$fdir'";
        $res = False;
    }
    my $ddir = "$home/$dotFontFactory/docs";
    mkdir $ddir;
    if not $ddir.IO.d {
        note "ERROR: unable to create dir '$ddir'";
        $res = False;
    }
    my $bdir = "$home/$dotFontFactory/bin";
    mkdir $bdir;
    if not $bdir.IO.d {
        note "ERROR: unable to create dir '$bdir'";
        $res = False;
    }

    # we have to do a couple of things:
    my $cnf = "$home/$dotFontFactory/Config.yml";
    if $cnf.IO.e {
        # if it exists, check it
        say "DEBUG: checking existing Config.yml file" if $debug;
        $res = check-config $cnf, :$debug;
    }

    if $res {
        # all is okay
        return $res;
    }

    #   if not, create it
    # extract the files in /resources and place in the /fonts or /docs
    # directory as appropriate
    my %h = get-resources-hash;
    for %h.kv -> $basename, $path {
        if $debug {
            note "DEBUG: basename: '$basename'";
            note "DEBUG: path    : '$basename'";
        }

        # get the content as a slurped string :bin
        my $bin = True;
        my $s = get-resource-content $path, :$bin;
        # spurt location depends on type of file
        if $basename ~~ /:i '.' [otf | ttf] $/ {
            if $debug {
                note "DEBUG: spurting: '{$fdir}/{$basename}'";
            }
            "$fdir/$basename".IO.spurt: $s, :$bin;
        }
        elsif $basename ~~ /:i '.' raku $/ {
            if $debug {
                note "DEBUG: spurting: '{$bdir}/{$basename}'";
            }
            "$fdir/$basename".IO.spurt: $s, :$bin;
        }
        else {
            if $debug {
                note "DEBUG: spurting: '{$ddir}/{$basename}'";
            }
            "$ddir/$basename".IO.spurt: $s, :$bin;
        }
    }

    # don't forget the Config.yml file
    create-config :$home, :$dotFontFactory, :$debug;

    # return final status
    $res;
}

sub check-config(
    $path, #= path to the config file
           #= to be checked
    :$debug,
    --> Bool
) is export {

    say "DEBUG: entering sub check-config..." if $debug;
    unless $path.IO.r {
        if $debug {
            note "DEBUG: no Config.yml found";
        }
        # then use create-config
        return False;
    }

    # we may be using the local repo dir, detect it here
    my $tdir = False;
    $tdir = True if $path.contains("local");

    my $err = 0;
    # assumption
    my $res = True;

    my %conf = load-yaml $path.IO.slurp;
    # expect 15 elements
    my $elems = %conf.elems;
    if $elems != 15 {
        say "WARNING: Conf.yml has $elems instead of the expected 15 elements.";
        $res = False;
        ++$err;
    }

    # format is ok, check the hash
    # check expected keys
    my %n = %FontFactory::X::FontHashes::number;
    for %n.keys -> $k {
        my $bnam = %(%n{$k})<basename>;
        my $expected-path = %(%n{$k})<path>;
        if $tdir and $expected-path.contains("tbrow") {
            # modify expected path
            my $cdir = $*CWD;
            $expected-path = "$cdir/tdir/FontFactory/fonts/$bnam";
        }

        say "DEBUG: font basename = '$bnam'" if $debug;
        # check each is in %conf
        if %conf{$bnam}:exists {
            my $local-path = %conf{$bnam};
            if $local-path eq $expected-path {
                # does $path exist?
                if $local-path.IO.r {
                    say "DEBUG: valid local font path: $local-path" if $debug;
                }
                else {
                    say "DEBUG: ERROR non-existing or unreadable local font path: $local-path" if $debug;
                    $res = False;
                    ++$err;
                }
            }
            else {
                say "DEBUG: ERROR unexpected local font path: $local-path" if $debug;
                say "             expected         font path: $expected-path" if $debug;
                $res = False;
                ++$err;
            }
        }
        else {
            say "DEBUG: ERROR basename $bnam key does not exist" if $debug;
            $res = False;
            ++$err;
        }
    }
    if not $res {
        note "ERROR: Found $err errors in your Config.yml file.";
        note "  Suggest you do the following:";
        note "    + save a copy of your existing Config.yml file";
        note "    + delete your '\$HOME/.FontFactory' directory and attempt a reinstallation";
        note "    + if still unsucessful, please file an issue";
        exit;
    }


    $res;
}
=end comment

sub locate-font(
    $font,
    :$debug,
    ) is export {
    # this sub is called by
    # sub find-freefont in module
    # FontFactory::BuildUtils,
    # but only if it's not already
    # in $HOME/.FontFactory/config.yml

    # we rely on the systems find
    # comand,

    my ($n, $s, $exit, $proc, @lines);
    my ($n2, $s2, @lines2);
    my $cmd;

    if $os.is-linux {
        $cmd = "find /usr/share/fonts -name";
    }
    elsif $os.is-macos {
        $cmd = "find -L /opt -name";
    }
    elsif $os.is-windows {
        $cmd = "find / -name";
    }

    my $f1 = "FreeSerif.otf";
    my $f2 = "XbrzaChiuS";

    # expect at least one find and no error
    $proc  = run $cmd, $f1, :out;
    @lines = $proc.out.slurp(:close).lines;
    $exit  = $proc.exitcode;
    $n = @lines.elems;
    $s = @lines.head // "";
    say "DEBUG s = '$s'" if $debug;

    # expect zero finds but no error
    $proc  = run $cmd, $f2, :out, :err;
    @lines  = $proc.out.slurp(:close).lines;
    @lines2 = $proc.err.slurp(:close).lines;
    $exit   = $proc.exitcode;

    $n  = @lines.elems;
    $n2 = @lines2.elems;
    $s  = @lines.head // "";
    $s2 = @lines2.head // "";
    say "DEBUG s  = '$s'" if $debug;
    say "DEBUG s2 = '$s2'" if $debug;
}
