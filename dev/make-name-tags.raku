#!/bin/env raku

use PDF::API6;
use PDF::Lite;
use PDF::Content::Color :ColorName, :color;

use lib "./lib";
use FreeFonts;
use MiscGraphics;

my %dims = get-dims-hash;

# TODO create a file name with date and time included
my $ofile = "Name-tags.pdf";
# input data file: rose-glass-patterns.dat
my $gfile = "rose-glass-patterns.dat";

my @names;
#my $names-file = "more-names.txt";
my $names-file = "less-names.txt";
for $names-file.IO.lines {
    next if $_ ~~ /\h* '#'/;

    my @w = $_.words;
    my $last = @w.pop;
    my $first = @w.shift;
    $first ~= " " ~ @w.pop if @w;
    my $name = "$last $first";
    @names.push: $name;
}
@names .= sort;
#.say for @names;
#exit;

my $Nclips = 3;

if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go | <csv file> [...options...]

    Given a list of names, writes them on reversible paper
      for a two-sided name tag on Letter paper.
    The front side of the first two-sided page will contain 
      job details (and the back side will be blank).

    Options:
      eg     - Produces $Nclips example PDFs. Currently there 
               are $Nclips examples numbered from 1 to $Nclips.

      eg=N   - With N, produces only PDF example N.
      egN

      show   - Gives details of the job based on the input name 
               list and card dimension parameters, then exits. 
               The information is the same as on the printed job 
               cover sheet.

    HERE
    exit
}

my $show      = 0;
my $debug     = 0;
my $landscape = 0;
my $go        = 0;
my $clip      = 0;

my $NC; # selected clip number [0..^$Nclips]
for @*ARGS {
    when /^ :i s/ { ++$show  }
    when /^ :i d/ { ++$debug }
    when /^ :i g/ { ++$go    }
    when /^ :i [e|c] \w*? ['='? (\d) ]? / {
        ++$clip;
        if $0.defined {
            $NC = +$0;
            $NC = $Nclips if $NC > $Nclips;
        }
    }
    default {
        say "Unknown arg '$_'...exiting.";
        exit;
    }
}

if $show {
    # TODO make a two-sided page of this:
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

# cols 2, rows 4, total 8, portrait
my @n = @names; # sample name "Mary Ann Deaver"


if $clip {
    for 0..^$Nclips -> $i {
        my $n = $i+1;
        next if $NC.defined and $n !== $NC;

        my $base-name = get-base-name($n);

        my PDF::Lite $pdf .= new;
        my $page = $pdf.add-page;
        $page.media-box = [0, 0, 8.5*72, 11*72];
        with $n {
            when $n == 3 {
                simple-clip3 :$page, :$debug;
                my $of = "$base-name.pdf";
                $pdf.save-as: $of;
                say "See example file: $of";
                exit if $NC.defined;;
            }
            when $n == 2 {
                simple-clip2 :$page, :$debug;
                my $of = "$base-name.pdf";
                $pdf.save-as: $of;
                say "See example file: $of";
                exit if $NC.defined;;
            }
            when $n == 1 {
                simple-clip1 :$page, :$debug;
                my $of = "$base-name.pdf";
                $pdf.save-as: $of;
                say "See example file: $of";
            }
        }
    }
    exit;
}

my PDF::Lite $pdf .= new;
$pdf.media-box = [0, 0, %dims<pw>, %dims<ph>];
my $page;
my $page-num = 0;
my $page0; # reference to the first page where XForm objects are stored
while @n.elems {

    # a new page of names <= 8
    my @p = @n.splice(0,8); # weird name

    say @p.raku if 0 and $debug;

    say "Working front page..." if $debug;
    # process the front page
    $page = $pdf.add-page;
    $page0 = $page if not $page0; # for XObject form storage

    # put first and last name found in top margin
    ++$page-num;
    make-badge-page @p, :side<front>, :$page, :$page-num, :$debug, :$page0;

    say "Working back page..." if $debug;
    # process the back side of the page
    $page = $pdf.add-page;
    # put first and last name found in top margin
    ++$page-num;
    make-badge-page @p, :side<back>, :$page, :$page-num, :$debug;

    =begin comment
    my @c = @p.batch(2);
    # new row with data for one or two
    # labels
    =end comment
}

# add page numbers: Page N of M
$pdf.save-as: $ofile;
say "See name tags file: $ofile";
