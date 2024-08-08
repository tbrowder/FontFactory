#!/usr/bin/env raku
use PDF::Lite;
use PDF::Font::Loader :load-font;
use FontFactory;
use FontFactory::Classes;
my $ff = FontFactory.new;
my $t12d5 = $ff.get-font: "t12d5"; # FreeSerif (Times), 12.5 points
my PDF::Lite $pdf .= new;
$pdf.add-page.text: {
    .font = $t12d5.font, $t12d5.size;
    .text-position = [10, 600];
    .say: "Hello, World!";
}
$pdf.save-as: "ff-example.pdf";

