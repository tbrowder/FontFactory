#!/usr/bin/env raku

use PDF::Lite;
use PDF::Font::Loader :load-font;

use lib "../lib";
use FreeFont;
use FreeFont::Classes;
my $ff = FreeFont.new;
my $t12d5 = $ff.get-font: "t12d5";
my PDF::Lite $pdf .= new;
$pdf.add-page.text: {
    .font = $t12d5.font, $t12d5.size;
    .text-position = [10, 600];
    .say: "Hello, World!";
}
$pdf.save-as: "example.pdf";

