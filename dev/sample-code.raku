#!/usr/bin/env raku

use PDF::Content;
use PDF::API6;
use PDF::Lite;

my $pdf = PDF::Lite.new;
my $page = $pdf.add-page;
$pdf.media-box = 0, 0, 8.5*72, 11*72;

sub do-clip($x, $y, :$page!) is export {
    my $g = $page.gfx;
    $g.Save; # save the CTM state
    $g.transform: :translate($x, $y);

    # draw a circle with no stroke or fill
    # ...
    $g.Clip;
    # note NO .Restore

    # call a sub to draw using the current clipping path
    draw-stuff :$page;

    # NOW restore the CTM
    $g.Restore; # <== if missing: DANGER Will Robinson!

    # on the $page the drawings from the draw-stuff sub
    # should be clipped to show only those portions
    # INSIDE the clip circle
}

sub draw-stuff(:$page!) is export {
    # the CTM origin should be at the same coords as the caller's origin
    # automatic .Save and .Restore
    $page.graphics: {
         # draw fancy stuff
         # more drawings...
    }
}
