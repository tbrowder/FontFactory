unit module GraphPaper;

use PDF::API6;
use PDF::Lite;
use PDF::Content::Color :ColorName, :color;

use FreeFonts;
use NameTags;

my $margins = 0.4 * 72;

# use letter paper
my $cell    = 0.1; # desired minimum cell size (inches)
my $cell-lw =   0; # very fine line
my $grid    =   5; # heavier line every X cells
my $grid-lw =   1; # heavier line width

sub make-graph-paper($ofil) {
}


