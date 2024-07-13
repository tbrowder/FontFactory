#!/usr/bin/env raku

my $f1 = "https://ftp.gnu.org/gnu/freefont/freefont-otf-20120503.tar.gz";
my $f2 = "https://ftp.gnu.org/gnu/freefont/freefont-otf-20120503.tar.gz.sig";

run "wget", $f1;
run "wget", $f2;
