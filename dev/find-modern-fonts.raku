#!/bin/env raku

use Abbreviations;
use Proc::Easier;
use Data::Dump;
use File::Find;
use Font::FreeType;
use Font::FreeType::Face;
use Font::FreeType::Raw::Defs;

use lib <../lib>;

use FontFactory;
use FontFactory::FF-Subs :build;

my $HOME = %*ENV<HOME> // '.';
my $pdir; # repo dir
my $cdir = $*CWD;
if $cdir ~~ /[bin|dev]$/ {
    $pdir = $cdir.parent;
}
elsif $cdir ~~ /Factory ['.git']? $/ {
    $pdir = '.';
}
else {
    die "FATAL: Unexpected parent directory '$pdir'";
}

my $ofil  = "$HOME/.fontfactory/system-fonts.list";
# created as an empty file if it doesn't exist, checked
# if it does:
my $ofil2 = "$HOME/.fontfactory/my-fonts.list";

# the following files are for development and are not generated
# if the 'build' mode is selected (unless 'debug' is selected)
my $ofil3 = "$pdir/dev/system-fonts.list";
my $ofil4 = "$pdir/dev/system-fonts-dups.list";
my $ofil5 = "$pdir/dev/fntsample-fonts.list";

if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go | build [debug]

    Finds TrueType, OpenType, and Type 1 font files and creates a list in
    a user's \$HOME in a new file (an old one is overwritten) named

        \$HOME/.fontfactory/system-fonts.list

    Creates the following empty file if it doesn't exist (checks it if it
    does):

        \$HOME/.fontfactory/my-fonts.list

    If the build mode is not used, other files generated are

        \$REPODIR/dev/system-fonts.list
        \$REPODIR/dev/system-fonts-dups.list
        \$REPODIR/dev/fntsample-fonts.list

    HERE
    exit;
}

my $debug = 0;
my $build = 0;
for @*ARGS {
    when /^:i d/ {
        ++$debug;
    }
    when /^:i g/ {
        ; # ok
    }
    when /^:i build/ {
        ++$build;
    }
}

if 0 and $debug {
    say "DEBUG: parent dir is: '$pdir'";
    exit;
}

# get the list using binary fc-list from package fontconfig
my $exe     = "fc-list";
my $res     = cmd $exe;
my @fc-list = $res.out.lines;

if 0 and $debug {
    .say for @fc-list;
    say "Found {@fc-list.elems} fc-list files";
    say "Debug: dumping fc-list after collecting the list. Early exit";
    exit;
}

my %fonts; # hash to hold fonts keyed by basename (keep suffix to show type)
my $dups   = 0;
my %dups;
my $maxlen = 0;
my $maxnam = '';
my $ft = Font::FreeType.new;
LINE: for @fc-list -> $line {
    # parse the line
    # the first field is the path to the font file
    my $path = $line.words.head;

    # skip all but standard system directories
    #   /usr/share/fonts
    #   /usr/share/X11/fonts/Type1
    #   /usr/share/X11/fonts/TTF
    #   /usr/local/share/fonts

    next LINE unless $path ~~ /^
        | '/usr/share/fonts'
        | '/usr/share/X11/fonts/Type1'
        | '/usr/share/X11/fonts/TTF'
        | '/usr/local/share/fonts'
    /;

    # not interested in other than these for now
    next LINE unless $path ~~ /'.' [otf|ttf|t1] ':' $/;

    # get rid of the closing ':'
    $path ~~ s/':'$//;

    # get the kern capability
    # must be scalable
    my $f = $ft.face: $path, :load-flags(FT_LOAD_NO_HINTING);
    next if not $f.is-scalable;

    my $font = $path.IO.basename;
    if %dups{$font}:exists {
        ++$dups;
        ++%dups{$font};
    }
    else {
        %dups{$font} = 1;;
    }

    my $dir  = $path.IO.parent;

    %fonts{$font}<dirs>{$dir} = 1;

    # mark fonts with kern data
    if $f.has-kerning {
        %fonts{$font}<has-kerning> = True;
    }
    else {
        %fonts{$font}<has-kerning> = False;
    }

    my $len = $font.chars;
    if $len > $maxlen {
        $maxlen = $len;
        $maxnam = $font;
    }
}

#ddt %fonts; exit;

# create the home .fontfactory dir if need be
my $hdir = "$HOME/.fontfactory";
unless $hdir.IO.d { mkdir $hdir; }

# create the home .fontfactory/my-fonts.list if it doesn't exist
# throw if it's not in the correct format
# add/check/correct for kerning
check-my-fonts-list $hdir, :free-type;

if 0 and $debug {
    # get abbreviations of the system fonts
    my $fonts = %fonts.keys.sort.join(' ');
    #say "  $_" for $fonts.words; exit;
    my @ab = abbreviations $fonts, :out-type(AL);
    say "  $_" for @ab; exit;
    my %ab = abbreviations $fonts;
    for %ab.sort -> $k {
        say "  $k";
        next;
        my $v = %ab{$k};
        say $v.WHAT;
        #say "$k : $v";
    }
    say "DEBUG exit"; exit;
}

# Create the "$HOME/.fontfactory/system-fonts.list" file
my $fh = open $ofil, :w;
my $index = 0;
my %fonts-indexed;
my @indices;
my $nkerning = 0;
for %fonts.keys.sort -> $font {
    ++$index;
    my $dir = %fonts{$font}<dirs>.head.key;
    my $kern = %fonts{$font}<has-kerning>;

    if $kern {
        $fh.say: sprintf '%4d %s %s HAS-KERNING', $index, $font, $dir;
    }
    else {
        $fh.say: sprintf '%4d %s %s', $index, $font, $dir;
    }


    ++$nkerning if $kern;
    %fonts{$font}<index> = $index;
    %fonts-indexed{$index} = { font => $font, dir => $dir, has-kerning => $kern };
    @indices.push: $index;
}
$fh.close;
# end creating the "$HOME/.fontfactory/system-fonts.list" file

exit if $build;

if $dups {
    $fh = open $ofil4, :w;
    for %fonts.keys.sort -> $font {
        if %fonts{$font}<dirs>.elems > 1 {
            $fh.say: $font;
            for %fonts{$font}<dirs>.keys.sort -> $dir {
                $fh.say: "    $dir";
            }
        }
    }
    $fh.close;
}

# write a detailed font list for the developer
$fh = open $ofil3, :w;
$index = 0;
for %fonts.keys.sort -> $font {
    ++$index;
    my $dir = %fonts{$font}<dirs>.head.key;
    $fh.say: sprintf '%4d %s %s', $index, $font, $dir;
}
$fh.close;

# write a plain font path list for use by 'fntsample'
$fh = open $ofil5, :w;
for %fonts.keys.sort -> $font {
    my $dir = %fonts{$font}<dirs>.head.key;
    $fh.say: "$dir/$font";
}
$fh.close;

say "Normal end.";
my $nf = %fonts.elems;
say "Found $nf TrueType, OpenType, and Type 1 font files.";
say "Found $dups duplicate font files." if $dups;
say "Found $nkerning fonts with kerning data.";
say "Creating a list of unique font files...";
say "  note: max length of basenames: $maxlen";
say "        basename:                $maxnam";
say "See output file '$ofil'.";
say "See output file '$ofil3'.";
if $dups {
    say "See output file '$ofil4'.";
}
say "See output file '$ofil5'.";
