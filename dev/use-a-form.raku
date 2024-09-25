#!/usr/bin/env raku

use PDF::API6;
use PDF::Lite;

use FreeFonts;

my %fonts = get-loaded-fonts-hash;
my $font = %fonts<tb>;

# the scanned files to be used as "watermarks"
my $w1 = "sample-form.pdf";
my $w2 = "sample-form-150dpi.pdf";
my $w3 = "sample-form-300dpi.pdf";

# my approach for now is to use pdftk
# but we need the overprint in an input file

# create the simple "input" pdf
my $ofil = "myinput.pdf";
my PDF::Lite $pdf .= new; #$ifil.open;
$pdf.media-box = [0, 0, 8.5*72, 11.0*72];
my $cx = 0.5 * 8.5*72;
my $cy = 0.5 * 11.0*72;

my PDF::Lite::Page $page = $pdf.add-page;
$page.graphics: {
    .transform: :translate[$cx, $cy];
    .transform: :rotate(0.25*pi);
    .font = $font, 20;
    .print: "Testing over printing a scanned form",
            :align<center>, :valign<center>;
}

$page.finish;
$pdf.save-as: $ofil;
say "See new pdf file: $ofil";
