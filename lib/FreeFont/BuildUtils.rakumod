unit module FreeFont::BuildUtils;

use PDF::Font::Loader :load-font;
use Text::Utils :split-line;
use YAMLish;
use QueryOS;

use FreeFont::X::FontHashes;
use FreeFont::Utils;
use FreeFont::Config;
use FreeFont::Resources;

my $os = OS.new;

sub find-freefont(
    $number,
    :$home!,
    :$dotFreeFont!,
    :$debug,
) is export {
    # return path to the file
    # use the font basename
    my ($path, $nam);
    $nam = %FreeFont::X::FontHashes::number{$number}<name>;
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

    # If the config.yml file exists, it
    # should already have the 15 paths
    # without using sub locate-font.

    my $config = "%*ENV<HOME>/$dotFreeFont/Config.yml";
    if $config.IO.r {
        # read yml
        my $str  = $config.IO.slurp;
        my %conf = load-yaml $str;
        $path    = %conf{$nam};
    }
    else {
        # Make the query to sub
        # locate-font
        # in module FreeFont::Utils
        $path = locate-font $nam;
    }

    $path
} # sub find-freefont(

sub manage-home-freefont(
    :$home!, 
    :$dotFreeFont!,
    :$debug,
    --> Bool
) is export {
    # path to the directory
    # for the config.yml file
    my $dir = "$home/$dotFreeFont";
    unless $dir.IO.d {
        mkdir $dir or return False;
    }

    my $res = False;

    #   We create three other
    #     subdirectories:
    #       .FreeFont/fonts
    #       .FreeFont/docs
    #       .FreeFont/bin
    my $fdir = "$home/$dotFreeFont/fonts";
    mkdir $fdir;
    if not $fdir.IO.d {
        note "ERROR: unable to create dir '$fdir'";
        $res = False;
    }
    my $ddir = "$home/$dotFreeFont/docs";
    mkdir $ddir;
    if not $ddir.IO.d {
        note "ERROR: unable to create dir '$ddir'";
        $res = False;
    }
    my $bdir = "$home/$dotFreeFont/bin";
    mkdir $bdir;
    if not $bdir.IO.d {
        note "ERROR: unable to create dir '$bdir'";
        $res = False;
    }

    # we have to do a couple of things:
    my $cnf = "$home/$dotFreeFont/Config.yml";
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

        # get the content as a slurped string
        my $s = get-resource-content $path;
        # spurt location depends on type of file
        if $basename ~~ /:i otf | ttf $/ {
            if $debug {
                note "DEBUG: spurting: '{$fdir}/{$basename}'";
            }
            "$fdir/$basename".IO.spurt: $s;
        }
        else {
            if $debug {
                note "DEBUG: spurting: '{$ddir}/{$basename}'";
            }
            "$ddir/$basename".IO.spurt: $s;
        }
    }

    # don't forget the Config.yml file
    create-config :$home, :$dotFreeFont, :$debug; 

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
    my %n = %FreeFont::X::FontHashes::number;
    for %n.keys -> $k { 
        my $bnam = %(%n{$k})<basename>;
        my $expected-path = %(%n{$k})<path>;
        if $tdir and $expected-path.contains("tbrow") {
            # modify expected path
            my $cdir = $*CWD;
            $expected-path = "$cdir/tdir/FreeFont/fonts/$bnam";
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
        note "    + delete your '\$HOME/.FreeFont' directory and attempt a reinstallation";
        note "    + if still unsucessful, please file an issue";
        exit;
    }


    $res;
}

sub locate-font(
    $font,
    :$debug,
    ) is export {
    # this sub is called by
    # sub find-freefont in module
    # FreeFont::BuildUtils,
    # but only if it's not already
    # in $HOME/.FreeFont/config.yml

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
