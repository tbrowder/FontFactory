#!/usr/bin/env raku

use PDF::API6;
use PDF::Lite;

use FreeFonts;

my %fonts = get-loaded-fonts-hash;
my $font = %fonts<tb>;

# the scanned files to be used as "watermarks"
my $w0 = "sample-form-fdf.pdf";
my $w1 = "sample-form.pdf";
my $w2 = "sample-form-150dpi.pdf";
my $w3 = "sample-form-300dpi.pdf";

for $w0, $w1, $w2, $w3 -> $ifil {
    my PDF::Lite $pdf .= new;
    $pdf.open: $ifil;
    my $npages = $pdf.pages.elems;
    say "Input file: $ifil";
    say "  number pages: $npages";

    say $pdf.raku;
    say $pdf.Root.raku;
    if $pdf<Catalog>:exists {
        say "Catalog exists";
    }

    next;
    if $pdf.page[0]<Resources>:exists {
        say "Resources exists";
    }
    if $pdf<Resources>:exists {
        say "Resources exists";
    }
    for $pdf.pages -> $page {
        note "some page!";
        say $page<Resources>;
    }
}



=finish

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
