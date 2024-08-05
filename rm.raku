#!/usr/bin/env raku

my @rem = <
    CMC7.txt
    COPYING.txt
    digitalGraphicLabs.html
    GPL-VERSION3.txt
    example.raku
    ff-font-samples.pdf
    micrenc-license.txt
    print-sample.raku
    CMC7.ttf
    GnuMICR.otf
    micrenc.ttf
    f.list
    DigitalGraphicLabs.html
>;
for @rem {
    unlink $_;
}

