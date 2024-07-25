#!/usr/bin/env raku

use PDF::Lite;
use PDF::Font::Loader :load-font;

# tmp lib line
use lib "../lib";

# codepoints to show for the micre and the cmc7 fonts
# micrenc 20 30 31 32 33 34 35 36 37 38 39 41 42 43 44 61 62 63 64    E0
# gnumicr 20 30 31 32 33 34 35 36 37 38 39 41 42 43 44             A9
# cmc7    20 30 31 32 33 34 35 36 37 38 39 41 42 43 44 61 62 63 64
my @f1cp = <gnumicr 20 30 31 32 33 34 35 36 37 38 39 41 42 43 44             A9>;
my @f2cp = <micrenc 20 30 31 32 33 34 35 36 37 38 39 41 42 43 44 61 62 63 64    E0>;
my @f3cp = <cmc7    20 30 31 32 33 34 35 36 37 38 39 41 42 43 44 61 62 63 64>;

use FreeFont;
use FreeFont::Classes;
use FreeFont::X::FontHashes;
use FreeFont::Utils;

constant $chars1 = <0123456789>;
constant $chars2 = <@#$&*()'l"%-+=/;:,.,!?;>;
constant $chars3 = <ABCCEFGHIJKLMNOPQRSTUVWXYZ>;
constant $chars4 = <abcdefghijklmnopqrstuvwxyz>;
my $text = "$chars1 $chars2 $chars3 $chars4";

my $ff = FreeFont.new;

my %h = %FreeFont::X::FontHashes::number;

my PDF::Lite $pdf .= new;
my $page = $pdf.add-page;
# landscape format, no transformation
# Letter
$pdf.media-box = [0, 0, 11*72, 8.5*72];

my $debug = 0;
$debug = 1 if @*ARGS.elems;

my ($x, $y);

# PAGE TITLE ====================
# center of the page for the title
$x = 0.5*11*72;
# in the top margin for the title
$y = 7.9*72;
my $Tfont = $ff.get-font: 3, 15;
my $page-title = "FreeFont GNU and MICRE Font Samples";
write-line $page, :font($Tfont), :text($page-title), :align<center>, :$x, :$y, :$debug;

# PAGE SUBTITLE =================
# center of the page for the subtitle
$x = 0.5*11*72;
# in the top margin for the subtitle
$y = 7.75*72-3;
my $Sfont = $ff.get-font: 1, 13;
my $page-subtitle = "(set at 12 points)";
write-line $page, :font($Sfont), :text($page-subtitle), :align<center>, :$x, :$y, :$debug;

# FONT LISTINGS =================
# page x, y for listings:
# page left margin
$x = 1*72*0.75;
$y = 7.5*72-5;
my $tfont  = $ff.get-font: 1;
my $indent = 36;

for 1...15 -> $n {
    #$debug = $n == 1 ?? 1 !! 0;

    if $n == 13 {
        # start a new page
        # reset y values
        # title the page
        $page = $pdf.add-page;
        $y = 7.5*72-5;
    }

    # default font size = 12;
    my $font;
    if $n < 13 {
        $font = $ff.get-font: $n, 12;
    }
    elsif $n == 13 {
        $font = $ff.get-font: $n, 30;
    }
    elsif $n == 14 {
        $font = $ff.get-font: $n, 12;
    }
    elsif $n == 15 {
        $font = $ff.get-font: $n, 20;
    }
    my $fo   = $font.font;
    my $face = $font.font.face;

    my $is-scalable = $face.is-scalable;
    say $is-scalable if $debug;

    my $leading = $n < 13 ?? ($face.height + 2) !! 18;
    say "leading = $leading" if $debug;

    my ($usiz, $ssiz);
    my $siz = $font.size;
    my $sfac = $siz/1000.0;


    # NEW METHODS FROM LATEST LOADER RELEASE 0.8.3
    # Underline Position, from the baseline where an underline should
    #  be drawn. This is usually negative and should be multipled by
    #  the font-size/1000 to get the actual position.
    $usiz = $fo.underline-position;
    say $face.underline-position if $debug;

    $ssiz = $usiz * $sfac;
    say "Underline position scaled: $ssiz (unscaled: $usiz)" if $debug;
    say $face.underline-thickness if $debug;

    #  underline-thickness Recommended underline thickness for the
    #  font. This should be multipled by font-size/1000.
    $usiz = $fo.underline-thickness;
    $ssiz = $usiz * $sfac;
    say "Underline thickness scaled: $ssiz (unscaled: $usiz)" if $debug;

    $usiz = $fo.height;
    $ssiz = $usiz * $sfac;
    say "Height scaled: $ssiz (unscaled: $usiz [misnamed, leading: baseline vert spacing])" if $debug;

    #say $fo.stringwidth;
    # method stringwidth(Str $text, Numeric $point-size?, Bool :$kern)
    #   returns Numeric
    # By default the computed size is in 1000's of a font
    # unit. Alternatively second `point-size` argument can be used to
    # scale the width according to the font size.

    =begin comment
    use PDF::Font::Loader::Glyph;
    my PDF::Font::Loader::Glyph @glyphs = $font.get-glyphs: "Hi";
    say "name:{.name} code:{.code-point} cid:{.cid} gid:{.gid} dx:{.dx} dy:{.dy}"
    for @glyphs;
    #Maps a string to glyphs, of type L<PDF::Font::Loader::Glyph>.
    =end comment

    if $debug {
        use PDF::Font::Loader::Glyph;
        my @glyphs = $fo.get-glyphs: "V";
        my $g = @glyphs.head;
        #say $g.gist;
        say $g.ax; # .dx deprecated, use .ax;
        say $g.ay;
        say $g.sx;
        say $g.sy;
    }

    if $n > 12 {
        # special fonts to handle
        # redefine $text
        my @cp;
        if $n == 13 {
            @cp = @f1cp;
        }
        elsif $n == 14 {
            @cp = @f2cp;
        }
        elsif $n == 15 {
            @cp = @f3cp;
        }
        for @cp -> $pair {
            # convert the pair to a char
            my $
        }
        $text = to-string @cp;
    }

    my $name = $font.name;
    write-line $page, :font($tfont), :text("$n - $name"), :$x, :$y, :$debug;
    $y -= $leading;
    write-line $page, :$font, :$text, :x($x+$indent), :$y, :$debug;
    $y -= $leading;

    last if $debug;

}

my $doc = "ff-font-samples.pdf";
$pdf.save-as: $doc;
say "See file '$doc'";

# subs to go in lib/
sub write-line(
    $page,
    :$font!,  # DocFont object
    :$text!,
    :$x!, :$y!,
    :$align = "left", # left, right, center
    :$valign = "baseline", # baseline, top, bottom
    :$debug,
) is export {

    $page.text: -> $txt {
        $txt.font = $font.font, $font.size;
        $txt.text-position = [$x, $y];
        # collect bounding box info:
        my ($x0, $y0, $x1, $y1) = $txt.say: $text, :$align, :kern;
        # bearings from baseline origin:
        my $tb = $y1 - $y;
        my $bb = $y0 - $y;
        my $lb = $x0 - $x;
	my $rb = $x1 - $x;
        my $width  = $rb - $lb;
        my $height = $tb - $bb;
        if $debug {
            say "bbox: llx, lly, urx, ury = $x0, $y0, $x1, $y1";
            say " width, height = $width, $height";
            say " lb, rb, tb, bb = $lb, $rb, $tb, $bb";
        }

    }
}

sub to-string(@cplist, :$debug --> Str) is export {
    # given a list of hex codepoints, convert them to a string repr
    # the first item in the list may be a string label
    my @list = @cplist;
    if @list.head ~~ Str { @list.shift };
    my $s = "";
    for @list -> $cpair {
        say "char pair '$cpair'" if $debug;
        # convert from hex to decimal
        my $x = parse-base $cpair, 16;
        # get its char
        my $c = $x.chr;
        say "   its character: '$c'" if $debug;
        $s ~= $c
    }
    $s
}
