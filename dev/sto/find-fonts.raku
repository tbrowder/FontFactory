#!/bin/env raku
use Proc::Easier;
use Data::Dump;
use Data::Dump::Tree;
use File::Find;

my $ofil  = "system-fonts.list";
my $ofil2 = "../lib/FontFactory/FontList.rakumod";
my $ofil3 = "FontList.rakumod";
my $ofil4 = "system-fonts-dups.list";
if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go | debug

    Finds TrueType, OpenType, and Type 1 font files and creates a list in
      a rakumod file named '$ofil'
      and two unique hashes in file '$ofil2'.
    HERE
    exit;
}

my $debug = 0;;
++$debug if @*ARGS.head ~~ /^:i d/;

# get the list using binary fc-list from package fontconfig
my $exe     = "fc-list";
my $res     = cmd $exe;
my @fc-list = $res.out.lines;

if $debug {
    .say for @fc-list;
    say "Found {@fc-list.elems} fc-list files";
    say "Debug: dumping fc-list after collecting the list. Early exit";
    exit;
}

my %fonts; # hash to hold fonts keyed by basename (eliminate extensions !~~ /'.' [otf|ttf|t1]
my $dups = 0;  
my %dups;  
my $maxlen = 0;
my $maxnam = '';
LINE: for @fc-list -> $line {
    # parse the line
    # the first field is the path to the font file
    my $path = $line.words.head;

    =begin comment
    if $path ~~ /'[' / {
        # don't know how to handle these
        next LINE;
    }
    =end comment

    # skip all but standard system directories
    # /usr/share/fonts
    # /usr/share/X11/fonts/Type1
    # /usr/share/X11/fonts/TTF
    # /usr/local/share/fonts
    # ~/.fonts

    #=begin comment
    next LINE unless $path ~~ /^
        | '/usr/share/fonts'
        | '/usr/share/X11/fonts/Type1'
        | '/usr/share/X11/fonts/TTF'
        | '/usr/local/share/fonts'
        | '~/.fonts'
    /;
    #=end comment

    next LINE unless $path ~~ /'.' [otf|ttf|t1] ':' $/;

    # get rid of the closing ':'
    $path ~~ s/':'$//;

    my $font = $path.IO.basename;
    if %dups{$font}:exists {
        ++$dups;
        ++%dups{$font}; 
    }
    else {
        %dups{$font} = 1;; 
    }

    my $dir  = $path.IO.parent;

    #%(%fonts{$font}<dirs>){$dir} = 1;
    %fonts{$font}<dirs>{$dir} = 1;

    my $len = $font.chars;
    if $len > $maxlen {
        $maxlen = $len;
        $maxnam = $font;
    }
}
 
#ddt %fonts; exit;

my $nf = %fonts.elems;
say "Found $nf TrueType, OpenType, and Type 1 font files.";
say "Found $dups duplicate font files." if $dups;

say "Creating a list of unique font files...";

my $fh = open $ofil, :w;
my $index = 0;
my %fonts-indexed;
my @indices;
for %fonts.keys.sort -> $font {
    ++$index;
    #my $dir = %(%fonts{$font}<dirs>).head;
    my $dir = %fonts{$font}<dirs>.head.key;
    $fh.say: sprintf '%4d %s %s', $index, $font, $dir;

    %fonts{$font}<index> = $index;
    %fonts-indexed{$index} = { font => $font, dir => $dir };
    @indices.push: $index;
}
$fh.close;

say "Creating a hash for FontFactory::FontList use...";
$fh = open $ofil2, :w;

# write the constant, top part
$fh.print: qq:to/HERE/;
unit module FontFactory::FontList;

constant %Fonts is export = [
    # These are the TrueType, OpenType, and Type 1 
    # fonts found on the local host as well as any
    # in file '\$HOME/.fontfactory/myfonts.list'.
HERE

my @b = %fonts.keys.sort;
# write the variable, middle part
for @b -> $font {
    #my $dir   = %(%fonts{$font}<dirs>).head;
    my $dir   = %fonts{$font}<dirs>.head.key;
    my $index = %fonts{$font}<index>;
    $fh.print: qq:to/HERE/;
        '$font' => \{ 
            index => $index,
              dir => '$dir',
        },
    HERE      
}

# write the constant, end part
$fh.print: qq:to/HERE/;
];

# invert the hash and have short names (aliases) as keys
constant %FontAliases is export = [
HERE      
# write the variable, middle part
for @indices -> $index {
    my $dir   = %fonts-indexed{$index}<dir>;
    my $font  = %fonts-indexed{$index}<font>;
    $fh.print: qq:to/HERE/;
        $index => \{ 
            font => '$font',
             dir => '$dir',
        },
    HERE      
}
$fh.say: '];';
$fh.close;

if $dups {
    $fh = open $ofil4, :w;
    for %fonts.keys.sort -> $font {
        if %fonts{$font}<dirs>.elems > 1 {
            $fh.say: $font;
            for %fonts{$font}<dirs>.keys -> $dir {
                $fh.say: "    $dir";
            }
        }
    }
    $fh.close;
}

# copy rakumod to the dev dir
copy $ofil2, $ofil3;

say "Normal end.";
say "  note: max length of basenames: $maxlen";
say "        basename:                $maxnam";
say "See output file '$ofil'.";
say "See output file '$ofil2'.";
say "See output file '$ofil3'.";
if $dups {
    say "See output file '$ofil4'.";
}
else {
}

