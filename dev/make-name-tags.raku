#!/bin/env raku

use PDF::API6;
use PDF::Lite;
use PDF::Content::Color :ColorName, :color;

use lib "./lib";
use NameTags;

my %dims = get-dims-hash;

# TODO create a file name with date and time included
my $ofile = "Name-tags.pdf";

my @names;
for "more-names.txt".IO.lines {
    my @w = $_.words;
    my $last = @w.pop;
    my $first = @w.shift;
    $first ~= " " ~ @w.pop if @w;;
    my $name = "$last $first";
    @names.push: $name;
}
@names .= sort;
#.say for @names;
#exit;

#my @names = "Missy Browder", "Tom Browder";

if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go | <csv file> [...options...]

    Given a list of names, writes them on reversible paper
      for a two-sided name tag on Letter paper.
    The first two-page will contain job details.

    Options:
      show - Gives details of the job based on the input name list
             and card dimension parameters, then exits. The information
             is the same as on the printed job cover sheet.

    HERE
    exit
}

my $show      = 0;
my $debug     = 0;
my $landscape = 0;
my $go        = 0;
for @*ARGS {
    when /^ :i s/ { ++$show  }
    when /^ :i d/ { ++$debug }
    when /^ :i g/ { ++$go    }
    default {
        say "Unknown arg '$_'...exiting.";
        exit;
    }
}

if $show {
    my ($nc, $nr, $hgutter, $vgutter) = show-nums;
    say "Badge width (inches):  {%dims<bwi>}";
    say "Badge height (inches): {%dims<bhi>}";

    say "Showing job details for portrait:";
    say "  number of badge columns: $nc";
    say "  number of badge rows:    $nr";
    say "  horizontal gutter space: $hgutter";
    say "  vertical gutter space:   $vgutter";
    say " Total badges: {$nc*$nr}";

    ($nc, $nr, $hgutter, $vgutter) = show-nums 1;
    say "Showing job details for landscape:";
    say "  number of badge columns: $nc";
    say "  number of badge rows:    $nr";
    say "  horizontal gutter space: $hgutter";
    say "  vertical gutter space:   $vgutter";
    say " Total badges: {$nc*$nr}";
    exit;
}

=begin comment
# rows
my $height = 1*72;
my $width  = 1.5*72;
my $x0     = 0.5*72;
my $y0     = 8*72;
for 1..3 -> $i {
    my $x = $x0 + $i * $width;
    my $text = "Number $i";
    draw-cell :$text, :$page, :x0($x), :$y0, :$width, :$height;
    write-cell-line :$text, :$page, :x0($x), :$y0, :$width, :$height,
    :Halign<left>;
$pdf.save-as: $ofile;
say "See output file: ", $ofile;
=end comment

# cols 2, rows 4, total 8, portrait
my @n = @names; # sample name "Mary Ann Deaver"
my PDF::Lite $pdf .= new;
$pdf.media-box = [0, 0, %dims<pw>, %dims<ph>];
my $page;
while @n.elems {

    # a new page of names <= 8
    #my @p = @n.batch(8);
    my @p = @n.splice(0,8); # weird name

    say @p.raku if 0 and $debug;

    say "Working front page...";
    # process the front page
    $page = $pdf.add-page;
    # put first and last name found in top margin
    make-front-side @p, :$page, :$debug;

    say "Working back page...";
    # process the back side of the page
    $page = $pdf.add-page;
    # put first and last name found in top margin
    make-back-side @p, :$page, :$debug;

    =begin comment
    my @c = @p.batch(2);
    # new row with data for one or two
    # labels
    =end comment
}

# add page numbers: Page N of M
$pdf.save-as: $ofile;
say "See name tags file: $ofile";

=finish
# now in ./lib/GBUMC.rakumod
#==== subroutines

sub write-cell-line(
    # text only
    :$text = "<text>",
    :$page!,
    :$x0!, :$y0!, # the desired text origin
    :$width!, :$height!,
    :$Halign = "center",
    :$Valign = "center",
) {
    $page.text: {
        # $x0, $y0 MUST be the desired origin for the text
        .text-transform: :translate($x0+0.5*$width, $y0-0.5*$height);
        .font = .core-font('Helvetica'), 15;
        with $Halign {
            when /left/   { :align<left> }
            when /center/ { :align<center> }
            when /right/  { :align<right> }
            default {
                :align<left>;
            }
        }
        with $Valign {
            when /top/    { :valign<top> }
            when /center/ { :valign<center> }
            when /bottom/ { :valign<bottom> }
            default {
                :valign<center>;
            }
        }
        .print: $text, :align<center>, :valign<center>;
    }
}

sub draw-cell(
    # graphics only
    :$text,
    :$page!,
    :$x0!, :$y0!, # upper left corner
    :$width!, :$height!,
    ) is export {

    # Note we bound the area by width and height and put any
    # graphics inside that area.
    $page.graphics: {
        .Save;
        .transform: :translate($x0, $y0);
        # color the entire form
        .StrokeColor = color Black;
        #.FillColor = rgb(0, 0, 0); #color Black
        .LineWidth = 2;
        .Rectangle(0, -$height, $width, $height);
        .Stroke; #paint: :fill, :stroke;
        .Restore;
    }
}
