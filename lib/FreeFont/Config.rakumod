unit module FreeFont::Config;

use QueryOS;
use FreeFont::X::FontHashes;

%number = %FreeFont::X::FontHashes::number;

my $os = OS.new;

# The subs and data in this file are
# used to construct all the required
# data in the $HOME/.FreeFont/ 
# directory.

# The installed GNU Free Fonts fonts are
# contained in different directories:

# Expected directory for installed files
# linux
#   /usr/share/fonts/opentype/freefont/
# macos
#   /opt/homebrew/Caskroom/font-freefont/20120503/freefont-20120503/
# windows # assumed same as windows
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

# create-config :$home, :$debug;
sub create-config(
    :$home!,
    :$dotFreeFont!,
    :$debug,
) is export {
    # the config file is at :
    my $dir  = "$home/$dotFreeFont";
    unless $dir.IO.d {
        mkdir $dir;
    }
    my $ofil = "$dir/Config.yml";
    my $fh = open $ofil, :w;

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
        # the path is in the user's '$HOME/$dotFreeFont' directory
        #my $f = %number{$n}<path>;
        my $f = "$dir/$b";

        my $s = sprintf("%-*.*s", $nc, $nc, $b);
        $s ~= ": $f";
        $fh.say: $s;
    }
    $fh.close;

    
}

