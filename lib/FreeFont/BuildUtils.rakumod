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
    # we have to do a couple of things:
    my $cnf = "$home/$dotFreeFont/Config.yml";
    if $cnf.IO.e {
        # if it exists, check it
        $res = check-config $cnf, :$debug;
    }


    #   if not, create it

    #   We check or create two other
    #     subdirectories:
    #       .FreeFont/fonts
    #       .FreeFont/docs
    my $fdir = "$home/$dotFreeFont/fonts";
    mkdir $fdir;
    my $ddir = "$home/$dotFreeFont/docs";
    mkdir $ddir;

    # extract the files in /resources and place in the /fonts or /docs
    # directory as appropriate
    my %h = get-resources-hash;
    for %h.kv -> $basename, $path { 
        # get the content as a slurped string
        my $s = get-resource-content $path;
        # spurt location depends on type of file
        if $basename ~~ /:i otf | ttf $/ {
            spurt "$fdir/$basename", $s;
        }
        else {
            spurt "$ddir/$basename", $s;
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
    unless $path.IO.r {
        return False;
    }
    my $status = True;

    my @lines = $path.IO.lines;
    return False if not @lines;
    for $path.IO.lines {
        when /^ \s* '#' / {
            ; # ok
        }
        when /^ \s*
            (\S+)   # a key
            \s* ':' # required colon
            (\S+)   # its value
            / {
            ; # ok
        }
        default {
            return False;
        }
    }

    # format is ok, check the hash
    my %conf = load-yaml $path.IO.slurp;
    # check expected keys
    my %n = %FreeFont::X::FontHashes::number;
    for %n.keys -> $k {
        my $name = %(%n{$k})<name>;
        say "DEBUG: font name = '$name'";
    }

    say %conf.gist;
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
