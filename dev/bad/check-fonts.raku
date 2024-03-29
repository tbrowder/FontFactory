#!/usr/bin/env raku

use lib <./lib ../lib>;
use PDF::Lite;
use Font::AFM;
use FontFactory;
use FontFactory::Subs;
use FontFactory::BaseFont;
use FontFactory::DocFont;
use FontFactory::FontList;

# test with a pdf doc
my $pdf = PDF::Lite.new;
my BaseFont @bf;
for %Fonts.keys.sort -> $f {
    my $BF = find-basefont :$pdf, :name($f);
    @bf.push: $BF;
}

my DocFont %df;
for (8,9,10,12.1) -> $size {
    for @bf -> $bf {
        # create a unique key for the font
        my $alias = %Fonts{$bf.name};
        my $key = "{$alias}{$size}";
        # replace decimal place with a 'd'
        $key ~~ s/'.'/d/;
        my $df = select-docfont :basefont($bf), :$size;
        %df{$key} = $df;
        say "Setting document font '{$bf.name}' at standard key '$key'";
    }
}
