#!/usr/bin/env raku

use PDF::Lite;
use PDF::Font::Loader :load-font;
use PDF::Content::FontObj;

my $file = "/usr/share/fonts/opentype/freefont/FreeSerif.otf";

my $f = load-font :$file;
say "\$f type: ", $f.^name;

my PDF::Lite $pdf .= new;
my $fsiz = 12;
$pdf.add-page.text: {
    .font = $f, $fsiz;
    .text-position = [10, 600];
    .say: "Hello, World!";
}
$pdf.save-as: "test.pdf";

