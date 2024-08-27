#!/usr/bin/env raku

my $csv = "gbumc-nametags.csv";

for $csv.IO.lines {
    my $s = $_;
    $s ~~ s:g/'"'/ /;
    $s ~~ s:g/','/ /;
    say $s;
}


