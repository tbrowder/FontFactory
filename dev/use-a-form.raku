#!/usr/bin/env raku

use PDF::API6;
use PDF::Lite;

use lib "./lib";
use FreeFonts;

my $p1 = "sample-form.pdf"; 
my $p2 = "sample-form-150dpi.pdf";
my $p3 = "sample-form-300dpi.pdf";

my $i=0;
for $p2, $p3 {
    ++$i;
    my $ver = $i;
    my $ifil = $_;
    my $ofil = "Form-v{$ver}.pdf";
    unless $ifil.IO.r {
        say "ERROR: Input file '$ifil' doesn't exist";
    }
    my PDF::Lite $pdf .= new; #$ifil.open;
dd $pdf.Catalog;

    exit;
    $pdf.open: $ifil;
 #   $pdf.finish;
    for $pdf.pages.kv -> $k, $v {
        say "page $k";
    }

    $pdf.save-as: $ofil;
    say "See new pdf file: $ofil";
    last;
}

