#!/usr/bin/env raku

use PDF::Lite;
use PDF::Font::Loader :load-font;

# tmp lib line
use lib "../lib";

use FreeFont;
use FreeFont::Classes;
use FreeFont::X::FontHashes;

constant $chars1 = <0123456789>;
constant $chars2 = <@#$&*()'l"%-+=/;:,.,!?;>;
constant $chars3 = <ABCCEFGHIJKLMNOPQRSTUVWXYZ>;
constant $chars4 = <abcdefghijklmnopqrstuvwxyz>;

my $ff = FreeFont.new;

my %h = %FreeFont::X::FontHashes::number;

my PDF::Lite $pdf .= new;
my $page = $pdf.add-page;
$page.media-box = [0, 0, 11*72, 8.5*72];

my $text = "$chars1 $chars2 $chars3 $chars4";
my $x = 1*72;
my $y = 7.5*72;
my $leading = 18; # = 18;
my $tfont  = $ff.get-font: 1;
my $indent = 36;
my $debug;

for 1..12 {
    $debug = $_ == 1 ?? 1 !! 0;
    
    # default font size = 12;
    my $font = $ff.get-font: $_;
    my $fo   = $font.font;
    my $face = $font.font.face;

    #$leading = $fo.height; # if $_ == 1;
    say "leading = $leading" if $debug;

    # NEW METHODS FROM LATEST LOADER RELEASE 0.8.3
    # Underline Position, from the baseline where an underline should
    #  be drawn. This is usually negative and should be multipled by
    #  the font-size/1000 to get the actual position.
    say $fo.underline-position;

    #  underline-thickness Recommended underline thickness for the
    #  font. This should be multipled by font-size/1000.
    say $fo.underline-thickness;

    say $fo.height; # misnamed, this is the recommended baseline vertical separation

    #say $fo.stringwidth;
    # method stringwidth(Str $text, Numeric $point-size?, Bool :$kern)
    #   returns Numeric
    # By default the computed size is in 1000's of a font
    # unit. Alternatively second `point-size` argument can be used to
    # scale the width according to the font size.

    use PDF::Font::Loader::Glyph;
    =begin comment
    use PDF::Font::Loader::Glyph;
    my PDF::Font::Loader::Glyph @glyphs = $font.get-glyphs: "Hi";
    say "name:{.name} code:{.code-point} cid:{.cid} gid:{.gid} dx:{.dx} dy:{.dy}"
    for @glyphs;
    #Maps a string to glyphs, of type L<PDF::Font::Loader::Glyph>.
    =end comment

    my @glyphs = $fo.get-glyphs: "V";
    my $g = @glyphs.head;
    say $g.gist;
    say $g.ax; # .dx deprecated, use .ax;
    say $g.ay;
    say $g.sx; 
    say $g.sy;

    my $name = $font.name;
    write-line $page, :font($tfont), :text($name), :$x, :$y, :$debug;
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
    :$debug,
) is export {

    $page.text: -> $txt {
        $txt.font = $font.font, $font.size;
        $txt.text-position = [$x, $y];
        # collect bounding box info:
        my ($x0, $y0, $x1, $y1) = $txt.say: $text, :$align, :kern;
        # bearings from baseline:
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
