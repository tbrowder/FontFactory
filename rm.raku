#!/usr/bin/env raku

my @rem = <
	CMC7.txt
	COPYING.txt
	DigitalGraphicLabs.html
	GPL-VERSION3.txt
	example.raku
	ff-font-samples.pdf
	micrenc-license.txt
	print-sample.raku
>;
for @rem {
    unlink $_;
}

