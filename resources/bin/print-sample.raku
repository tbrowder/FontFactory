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

my $text = "$chars1 $chars2 $chars3 $chars4";
my $x = 1*72;
my $y = 10*72;
for 1..12 {
    my $font = $ff.get-font: $_;
    write-line $page, :$font, :$text, :$x, :$y;
}

=begin comment
$pdf.add-page.text: {
    .font = $t12d5.font, $t12d5.size;
    .text-position = [10, 600];
    .say: "Hello, World!";
}
=end comment

$pdf.save-as: "ff-font-samples.pdf";

# subs to go in lib/
sub write-line(
    $page,
    :$font!,  # DocFont object
    :$text!,
    :$x!, :$y!,
    :$align = "left", # left, right, center
    :$debug,
) is export {

    $page.text: {
        .font = $font.font, $font.size;
        .text-position = [$x, $y];
        .say: $text, :$align;
    }
}
