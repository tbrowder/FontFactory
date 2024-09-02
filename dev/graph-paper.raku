#!/bin/env raku

use PDF::API6;
use PDF::Lite;
use PDF::Content::Color :ColorName, :color;

use lib "./lib";
use NameTags;
use GraphPaper;

my $margins = 0.4 * 72;
# use letter paper
my $cell    = 0.1; # desired minimum cell size (inches)
my $cell-lw =   0; # very fine line
my $grid    =   5; # heavier line every X cells
my $grid-lw =   1; # heavier line width
my $ofil    = "graph-paper.pdf";
if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go [...options...]

    Produces a graph-paper version on Letter paper with
      {$cell}-inch x {$cell}-inch small cells and heavier lines
      every $grid cells.
    The output is a PDF document for US Letter paper.

    The default output file name is '$ofil', but can be 
    changed with option 
        'pdf=X' 
    where X is the desired file name;

    HERE
    exit
}

for @*ARGS {
    when /^ :i pdf '=' (\S+) /{
        $ofil = ~$0;    
    }
}

make-graph-paper $ofil;
