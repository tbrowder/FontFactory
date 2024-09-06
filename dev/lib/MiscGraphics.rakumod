unit module MiscGraphics;

use PDF::API6;
use PDF::Lite;
use PDF::Content::Color :ColorName, :color;

use FreeFonts;

# Letter paper
#==============
# letter, portrait
my $pw = 8.5*72;
my $ph = 11*72;
#==============

# Allow at least a 1/2-inch margin at the top
# for page number and first and last names on the
# sheet. Allow 1/4-inch margins elsewhere.
# Total margins vertically:   0.75"
# Total margins horizontally: 0.5"

# To allow reverse-printing, each list of names
# on a front row will be reversed on the reverse
# side.

# current badge dimensions (width, height)
my @badge = 3.84, 2.26; # Amazon, 0.1" less than listed dimensions to allow in-pocket
my $bwi = @badge.head; # badge width
my $bhi = @badge.tail; # badge height
# all dimens in PS points:
my $bw = $bwi * 72; # badge width
my $bh = $bhi * 72; # badge height
my $hm = 0.5*72;  # total horizontal margins
my $vm = 0.75*72; # total vertical margins

# Given 2 columns x 4 rows per page and the
# margins and gutters, we need to define
# midpoints of each badge.
# Per row, margins are 0.5" total. Midpoint
# in width is 4.25". Give 1/4" between badges. Then:
my $mx = 4.25 * 72;
my $dx = (0.125 + (0.5 * $bwi)) * 72;
my $h1 = $mx - $dx;
my $h2 = $mx + $dx;

# Allow 1/4" between rows. Top of first
# row 0.5" with 1/14" between rows.
my $v1 = (11 - 0.5 - (0.5 * $bhi)) * 72;
my $dy = ($bhi + 0.25) * 72;
my $v2 = $v1 - $dy;
my $v3 = $v2 - $dy;
my $v4 = $v3 - $dy;

# With remaining
# space of 7",
our %dims = %(
  bwi => $bwi,
  bhi => $bhi,
  bw  => $bwi * 72, # badge width
  bh  => $bhi * 72, # badge height
  hm  => 0.5*72,    # horizontal margins
  vm  => 0.75*72,   # vertical margins
  pw  => $pw,
  ph  => $ph,
);

my %fonts = get-loaded-fonts-hash;

#==== subroutines
sub get-dims-hash(--> Hash) is export {
    # name tag dimensions
    %dims;
}

sub make-badge-page(
    @p,       # list of 8 or less names for a page
    :$side! where $side ~~ /front | back/,
    :$page!,
    :$page-num!,
    :$debug,
) is export {
    my @r = @p;
    my (@c, $n); #    cy     cx      cx
    my ($vmid, $hmid1, $hmid2);

    # For front wide, work row cells left to right.
    #   cell 1 | cell 2
    # For back side, work row cell right to left.
    #   cell 2 | cell 1

    say "Page $page-num (a $side side)" if $debug;
    my $rnum = 0;
    while @r.elems {
        my $ncells = 1;
        my $nam1 = @r.shift;
        my $nam2 = @r.elems ?? @r.shift !! 0;
        ++$ncells if $nam2;

        ++$rnum;
        # get the cell midpoints
        if $rnum == 1 { $vmid = $v1 }
        if $rnum == 2 { $vmid = $v2 }
        if $rnum == 3 { $vmid = $v3 }
        if $rnum == 4 { $vmid = $v4 }

        $hmid1 = $h1; # for front side
        $hmid2 = $h2; # for front side
        say "  row $rnum with $ncells badges" if $debug;

        my $cy = $vmid;
        # make the labels at their correct locations
        if $side eq "front" {
            # cell 1 on left
            # cell 2 on right
        }
        else {
            # cell 1 on right
            # cell 2 on left
            $hmid1 = $h2; # for back side
            $hmid2 = $h1; # for back side
        }

        make-label($nam1, :width($bw), :height($bh), :cx($hmid1), :$cy, :$page);
        make-label($nam2, :width($bw), :height($bh), :cx($hmid2), :$cy, :$page)
            if $nam2;
    }

} # sub make-badge-page(

sub make-label(
    $text,        # string: "last first middle"
    :$width,      # points
    :$height,     # points
    :$cx!, :$cy!, # points
    :$page!,
    :$debug,
    # default color for top portion is blue

) is export {
    # translate to the center
    #   blue the top section
    #   GBUMC in white in blue section
    #   first (and any middle) name in middle section
    #   last name in lower section
    #
    # outline the labels with a 0 width interior line

    # Note we bound the area by width and height and put any
    # graphics inside that area.

    # label constants for tweaking (in points):
    # for now the cross will be a circle enclosing a symmetrical +
    #   colored white on the blue background
    my $cross-diam;
    my $cross-thick;
    my $crossX;
    my $crossY;

    # valign value from top of label
    my $line1Y     = (0.15) * $height;                # 0.3 size of label
    my $line1size  = 25;
    my $line2Y     = (0.3 + 0.1725) * $height;        # 0.35 size of label
    my $line2size  = 40;
    my $line3Y     = (0.3 + 0.35 + 0.1725) * $height; # 0.35 size of label
    my $line3size  = 40;

    # cross/rose window params
    my $diam = 0.35*72;
    my $thick = 3;
    my $cwidth = 1*72;
    my $cheight = 0.3 * 72;
    my $ccxL = $cx - ($width * 0.5);
    my $ccxR = $cx + ($width * 0.5);
    my $cross-offset = 30;
    $ccxL += $cross-offset; # center of cross 30 points right of left side
    $ccxR -= $cross-offset; # center of cross 30 points left of right side
    my $ccy = $cy + ($height * 0.5) - $line1Y;

    #==========================================
    # the rectangular outline
    $page.graphics: {
        # translate to top-left corner
        my $ulx = $cx - 0.5 * $width;
        my $uly = $cy + 0.5 * $height;

        .transform: :translate($ulx, $uly);
        .StrokeColor = color Black;
        #.FillColor = rgb(0, 0, 0); # color Black
        .LineWidth = 0;
        .Rectangle(0, -$height, $width, $height);
        .Stroke; #paint: :fill, :stroke;
    }

    #==========================================
    # the upper blue part
    my $blue = [0, 102, 255]; # from color picker
    $page.graphics: {
        # translate to top-left corner
        my $ulx = $cx - 0.5 * $width;
        my $uly = $cy + 0.5 * $height;
        .transform: :translate($ulx, $uly);
        .FillColor = color $blue; #[0, 0, 0.3]; #Navy; #rgb(0, 0, 0.5);
        .LineWidth = 0;
        # the height is part of label $height
        my $bh = $height * 0.3;
        .Rectangle(0, -$bh, $width, $bh);
        .paint: :fill, :stroke;
    }

    #==========================================
    # the "master" subs that create the entire cross symbols, including
    # the rose window background

    make-cross(:$diam, :$thick, :width($cwidth),
                :height($cheight), :cx($ccxL), :cy($ccy), :$page, :$debug);
    make-cross(:$diam, :$thick, :width($cwidth),
                :height($cheight), :cx($ccxR), :cy($ccy), :$page, :$debug);

    #==========================================
    # gbumc text in the blue part
    $page.graphics: {
        .Save;
        my $gb = "GBUMC";
        my $tx = $cx;
        my $ty = $cy + ($height * 0.5) - $line1Y;
        .transform: :translate($tx, $ty); # where $x/$y is the desired reference point
        .FillColor = color White; #rgb(0, 0, 0); # color Black
        .font = %fonts<hb>, #.core-font('HelveticaBold'),
                 $line1size; # the size
        .print: $gb, :align<center>, :valign<center>;
        .Restore;
    }

    #==========================================
    # the congregant names on two lines
    my @w = $text.words;
    my $last = @w.shift;
    my $first = @w.shift;
    my $middle = @w.elems ?? @w.shift !! 0;
    $first = "$first $middle" if $middle;
    say "first: $first" if $debug;
    say "last: $last" if $debug;

    # line 2 (first name), grays:
    my $tcolor = 0.2; #[72, 72, 72]; # 0.7;

    $page.graphics: {
        .Save;
        # translate to top-middle
        my $uly = $cy + 0.5 * $bh;
        my $tx = $cx;
        my $ty = $cy + ($height * 0.5) - $line2Y;

        # TWEAK down
        $ty -= 5;
        .transform: :translate($tx, $ty); # where $x/$y is the desired reference point
        #.text-transform: :translate($tx, $ty);
        .FillColor = color $tcolor; #Black; #rgb(0, 0, 0); # color Black
        .font = %fonts<hb>, #.core-font('HelveticaBold'),
                 $line2size; # the size
        .print: $first, :align<center>, :valign<center>;
        .Restore;
    }

    # line 3 (last name)
    $page.graphics: {
        .Save;
        # translate to top-middle
        my $uly = $cy + 0.5 * $bh;
        my $tx = $cx;
        my $ty = $cy + ($height * 0.5) - $line3Y;

        # TWEAK up
        $ty += 5;
        .transform: :translate($tx, $ty); # where $x/$y is the desired reference point
        #.text-transform: :translate($tx, $ty);
        .FillColor = color $tcolor; #Black; #rgb(0, 0, 0); # color Black
        .font = %fonts<hb>, #.core-font('HelveticaBold'),
                 $line3size; # the size
        .print: $last, :align<center>, :valign<center>;
        .Restore;
    }

    #==========================================
    # label is done

} # sub make-label(

=begin comment
our &draw-disk = &draw-ring;
sub draw-ring(
    $x, $y,  # center point
    $r,      # radius
    :$thick!,
    :$page!,
    :$fill = True, # else stroke
    :$color = [1], # white
    :$linewidth = 0,
    ) is export {

    # need inside clip of a disk
    # first draw the outer circle path clockwise
    # then draw the inner circle path counterclockwise
    # then clip

    $page.graphics: {
        .Save;
        .SetLineWidth: $linewidth; #, :$color;
	.StrokeColor = color $color;
	.FillColor   = color $color;
        # from stack overflow: copyright 2022 by Spencer Mortenson
        .transform: :translate[$x, $y];
        constant c = 0.551915024495;

        # outer cicle
        .MoveTo: 0*$r, 1*$r; # top of the circle
        # use four curves, counterclockwise (positive direction)
        .CurveTo: -1*$r,  c*$r, -c*$r,  1*$r,  0*$r,  1*$r;
        .CurveTo: -c*$r, -1*$r, -1*$r, -c*$r, -1*$r,  0*$r;
        .CurveTo:  1*$r, -c*$r,  c*$r, -1*$r,  0*$r, -1*$r;
        .CurveTo:  c*$r,  1*$r,  1*$r,  c*$r,  1*$r,  0*$r;
        #.ClosePath;

        # inner circle
        my $R = $r - $thick;
        .MoveTo: 0*$R, 1*$R; # top of the circle
        # use four curves, clockwise (negative direction)
	.StrokeColor = color [0]; # black$color;
	.FillColor   = color [0]; # black$color;
        .CurveTo:  c*$R,  1*$R,  1*$R,  c*$R,  1*$R,  0*$R;
        .CurveTo:  1*$R, -c*$R,  c*$R, -1*$R,  0*$R, -1*$R;
        .CurveTo: -c*$R, -1*$R, -1*$R, -c*$R, -1*$R,  0*$R;
        .CurveTo: -1*$R,  c*$R, -c*$R,  1*$R,  0*$R,  1*$R;
        .ClosePath;
        .Clip;

        if $fill and $stroke {
            .FillStroke;
        }
        elsif $fill {
            .Fill;
        }
        elsif $stroke {
            .Stroke;
        }
        .Restore;
    }
}
=end comment

# My initial guess at the rose window colors (rgb triplets)
# based on my comparing the image on the church website
# to the W3C rgb color picker website.
#
# I may update the values as needed after seeing printed results.
constant %colors = %(
    1 => [255, 204, 102],
    2 => [  0,   0,   0],
    3 => [153, 204, 255],
    4 => [  0, 102, 255],
    5 => [ 51, 153, 102],
    6 => [204,  51,   0],
);

sub draw-cross(
    :$height!,
    :$width = $height, # default is same as height
    :$hcross = 0.5, # ratio of height and distance of crossbar from the top
    :$thick!,
    :$page!,
    ) is export {
}

sub make-cross(
    # overall dia
    :$diam!,
    :$thick!,
    :$width!,     # points
    :$height!,    # points
    :$cx!, :$cy!, # points
    :$page!,
    :$debug,
    # default color is white
) is export {

    # initial model will be a hollow circle with symmetrical spokes in
    # shape of a cross, with a rose background color to simulate
    # GBUMC's rose window
    my $radius = $diam*0.5;

    # create a white, filled, thinly stroked circle of the total
    # diameter
    # draw a white circle with a black center hole
    draw-circle $cx, $cy, $radius, :fill-color(1), :fill, :$page;
    draw-circle $cx, $cy, $radius-$thick, :fill-color(0), :fill, :$page;

# good to this point
# TODO get it going!!

    # create a clipped, inner circular path with radius inside
    # by the thickness
    # create the stained-glass portion
    # as a rectangular pattern set
    # to the height and width of the circle
# clip inside this sub:
#draw-color-wheel :$cx, :$cy, :$radius, :$page;

    =begin comment
    # 4 pieces
    my ($lrx, $lry, $llx, $lly, $urx, $ury, $ulx, $uly);
    my ($width-pts);
    my ($stroke-color, $fill-color) = 1, 0;
    # upper left rectangle
    draw-ul-rect :$llx, :$lly, :$width, :$height, :$width-pts,
                 :$stroke-color, :$fill-color, :$page;
    # upper right rectangle
    draw-ur-rect :$llx, :$lly, :$width, :$height, :$width-pts,
                 :$stroke-color, :$fill-color, :$page;
    # lower left rectangle
    draw-ll-rect :$llx, :$lly, :$width, :$height, :$width-pts,
                 :$stroke-color, :$fill-color, :$page;
    # lower right rectangle
    draw-lr-rect :$llx, :$lly, :$width, :$height, :$width-pts,
                 :$stroke-color, :$fill-color, :$page;
    =end comment


    # create the white spokes




    =begin comment
    # inner filled with rose
    my $rose = [255, 153, 255]; # from color picker
    draw-circle $cx, $cy, $radius-$thick, :color($rose), :$page;

    # outer filled with white with a cross inside as part of it
    # is placed over the "rose" part
    draw-circle $cx, $cy, $radius, :color(1), :$page;
    =end comment

    =begin comment
    $page.graphics: {
        .Save;
        .transform: :translate($cx, $cy);
        #.StrokeColor = color Black;
        .FillColor = Blue; #rgb(0, 0, 0); #color Black
        #.LineWidth = 2;
        .Rectangle(0, -$height, $width, $height);
        .paint: :fill, :stroke;
        .Restore;
    }
    =end comment

} # sub make-cross(

sub draw-circle(
    $x, $y, $r,
    :$page!,
    :$stroke-color = [0], # black
    :$fill-color   = [1], # white
    :$linewidth = 0,
    :$fill,
    :$stroke,
    :$clip,
) is export {
    $page.gfx: {
        .Save if not $clip;
        .SetLineWidth: $linewidth; #, :$color;
	.StrokeColor = color $stroke-color;
	.FillColor   = color $fill-color;
        # from stack overflow: copyright 2022 by Spencer Mortenson
        .transform: :translate[$x, $y];
        constant c = 0.551915024495;

        #=begin comment
        .MoveTo: 0*$r, 1*$r; # top of the circle
        # use four curves, clockwise
        .CurveTo:  c*$r,  1*$r,  1*$r,  c*$r,  1*$r,  0*$r;
        .CurveTo:  1*$r, -c*$r,  c*$r, -1*$r,  0*$r, -1*$r;
        .CurveTo: -c*$r, -1*$r, -1*$r, -c*$r, -1*$r,  0*$r;
        .CurveTo: -1*$r,  c*$r, -c*$r,  1*$r,  0*$r,  1*$r;
        .ClosePath;
        #=end comment
        =begin comment
        .MoveTo: 0*$r, 1*$r; # top of the circle
        # use four curves, counter-clockwise
        .CurveTo: -1*$r,  c*$r, -c*$r,  1*$r,  0*$r,  1*$r;
        .CurveTo: -c*$r, -1*$r, -1*$r, -c*$r, -1*$r,  0*$r;
        .CurveTo:  1*$r, -c*$r,  c*$r, -1*$r,  0*$r, -1*$r;
        .CurveTo:  c*$r,  1*$r,  1*$r,  c*$r,  1*$r,  0*$r;
        .ClosePath;
        =end comment

        if not $clip {
            if $fill and $stroke {
                .FillStroke;
            }
            elsif $fill {
                .Fill;
            }
            elsif $stroke {
                .Stroke;
            }
            .Restore;
        }
        else {
            #.Clip; # .EOClip; # ??
            .EOClip; # ??
        }
    }
} # sub draw-circle(

sub write-cell-line(
    # text only
    :$text = "<text>",
    :$page!,
    :$x0!, :$y0!, # the desired text origin
    :$width!, :$height!,
    :$Halign = "center",
    :$Valign = "center",
) is export {
    =begin comment
    # simple version
    $page.text: {
        # $x0, $y0 MUST be the desired origin for the text
        .text-transform: :translate($x0+0.5*$width, $y0-0.5*$height);
        .font = .core-font('Helvetica'), 15;
        .print: $text, :align<center>, :valign<center>;
    }
    =end comment
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
} # sub write-cell-line(

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
} # sub draw-cell(

# algorithms
sub show-nums($landscape = 0) is export {
    my ($nc, $nr, $hgutter, $vgutter);
    my $W = $pw;
    my $H = $ph;
    if $landscape {
        $W = $ph;
        $H = $pw;
        # landscape
        #   num cols of cards
        $nc = ($W - $hm) div $bw;
        #   num rows of cards
        $nr = ($H - $vm) div $bh;

        $hgutter = ($W - ($nc * $bw)) / ($nc - 1);
        $vgutter = ($H - ($nr * $bh)) / ($nr - 1);
    }
    else {
        # portrait
        #   num cols of cards
        $nc = ($W - $hm) div $bw;
        #   num rows of cards
        $nr = ($H - $vm) div $bh;

        $hgutter = ($W - ($nc * $bw)) / ($nc - 1);
        $vgutter = ($H - ($nr * $bh)) / ($nr - 1);
    }
    # convert gutter space back to inches
    $hgutter /= 72.0;
    $vgutter /= 72.0;
    $nc, $nr, $hgutter, $vgutter
} # sub show-nums($landscape = 0) is export {

# upper-left quadrant
sub draw-ul-rect(
    :$llx!,       # in centimeters
    :$lly!,       # in centimeters
    :$width!,     # in centimeters
    :$height!,    # in centimeters
    :$width-pts!, # in desired PS points, scale cm dimens accordingly
    # probably don't need these
    :$stroke-color = [0], # black
    :$fill-color   = [1], # white
    :$page!,
    ) is export {
    # on the sketch are 10 rectangle numbers, use them here
    # also rgb colors are on the sketch for some blocks
    # the sketch is accompanied by a graph drawing showing blown-up
    #   dimensions in centimeters which must be scaled down by the
    #   appropriate factor
    # pane 1 rgb: 204, 51, 0
    draw-rectangle :llx(0), :lly(0), :width(20), :height(20),
                   :$stroke-color, :$fill-color, :$page;
    # pane 2 rgb:
    # pane 3 rgb: 153, 204, 255
    # pane 4 rgb: 0, 0, 0
    # pane 5 rgb: 255, 204, 102
    # pane 6 rgb:
    # pane 7 rgb:
    # pane 8 rgb:
    # pane 9 rgb: 0, 102, 255
    # pane 10 rgb: 51, 153, 102
}

# upper-right quadrant
sub draw-ur-rect(
    :$llx!,  # in centimeters
    :$lly!,  # in centimeters
    :$xlen!, # in desired PS points, scale accordingly
    :$stroke-color = [0], # black
    :$fill-color   = [1], # white
    :$page!,
    ) is export {
}

# lower-left quadrant
sub draw-ll-rect(
    :$llx!,  # in centimeters
    :$lly!,  # in centimeters
    :$xlen!, # in desired PS points, scale accordingly
    :$stroke-color = [0], # black
    :$fill-color   = [1], # white
    :$page!,
    ) is export {
}

# lower-right quadrant
sub draw-lr-rect(
    :$llx!,  # in centimeters
    :$lly!,  # in centimeters
    :$xlen!, # in desired PS points, scale accordingly
    :$stroke-color = [0], # black
    :$fill-color   = [1], # white
    :$page!,
    ) is export {
}

sub draw-rectangle(
    :$llx!,
    :$lly!,
    :$width!,
    :$height!,
    :$stroke-color = [0], # black
    :$fill-color   = [1], # white
    :$fill is copy,
    :$stroke is copy,
    :$page!,
    ) is export {

    $stroke = False if not $stroke.defined;
    $fill   = False if not $fill.defined;
    if not ($fill or $stroke) {
        # make stroke the default
        $stroke = True;
    }

    $page.graphics: {
        .Save;
        # translate to lower-left corner
        .transform: :translate($llx, $lly);
        .FillColor = color $fill-color;
        .StrokeColor = color $stroke-color;
        .LineWidth = 0;
        .MoveTo: $llx, $lly;
        .LineTo: $llx+$width, $lly;
        .LineTo: $llx+$width, $lly+$height;
        .LineTo: $llx       , $lly+$height;
        .ClosePath;

        if $fill and $stroke {
            .FillStroke;
        }
        elsif $fill {
            .Fill;
        }
        elsif $stroke {
            .Stroke;
        }
    }
} # sub draw-rectangle(

my $page-margins   = 0.4 * 72;
# use letter paper
my $cell-size      = 0.1; # desired minimum cell size (inches)
   $cell-size     *= 72;  # now in points
my $cells-per-grid = 10;  # heavier line every X cells

my $cell-linewidth     =  0; # very fine line
my $mid-grid-linewidth =  0.75; # heavier line width (every 5 cells)
my $grid-linewidth     =  1.40; # heavier line width (every 10 cells)

sub make-graph-paper($ofil) is export {
    # Determine maximum horizontal grid squares for Letter paper,
    # portrait orientation, and 0.4-inch horizontal margins.
    my $page-width  = 8.5 * 72;
    my $page-height = 11  * 72;
    my $max-graph-size = $page-width - $page-margins * 2;
    my $max-ncells = $max-graph-size div $cell-size;

    my $ngrids = $max-ncells div $cells-per-grid;
    my $graph-size = $ngrids * $cells-per-grid * $cell-size;
    my $ncells = $ngrids * $cells-per-grid;
    say qq:to/HERE/;
    Given cells of size $cell-size x $cell-size points, with margins,
      with grids of $cells-per-grid cells per grid = $ngrids.
    HERE

    my $pdf  = PDF::Lite.new;
    $pdf.media-box = 0, 0, $page-width, $page-height;
    my $page = $pdf.add-page;

    # Translate to the lower-left corner of the grid area
    my $llx = 0 + 0.5 * $page-width - 0.5 * $graph-size;
    my $lly = $page-height - 72 - $graph-size;
    $page.graphics: {
        .transform: :translate($llx, $lly);

        # draw horizontal lines, $y is varying 0 to $twidth
        #   bottom to top
        for 0..$ncells -> $i {
            my $y = $i * $cell-size;
            if not $i mod 10 {
                .LineWidth = $grid-linewidth;
            }
            elsif not $i mod 5 {
                .LineWidth = $mid-grid-linewidth;
            }
            else {
                .LineWidth = $cell-linewidth;
            }
            .MoveTo: 0,           $y;
            .LineTo: $graph-size, $y;
            .Stroke;
        }
        # draw vertical lines, $x is varying 0 to $twidth
        #   left to right
        for 0..$ncells -> $i {
            my $x = $i * $cell-size;
            if not $i mod 10 {
                .LineWidth = $grid-linewidth;
            }
            elsif not $i mod 5 {
                .LineWidth = $mid-grid-linewidth;
            }
            else {
                .LineWidth = $cell-linewidth;
            }
            .MoveTo: $x, 0;
            .LineTo: $x, $graph-size;
            .Stroke;
        }
    }

    $pdf.save-as: $ofil;
    say "See output file: '$ofil'";
} # sub make-graph-paper($ofil) is export {

sub deg2rad($degrees) {
    $degrees * pi / 180
}

sub rad2deg($radians) {
    $radians * 180 / pi
}

sub draw-color-wheel(
    :$cx!, :$cy!,
    :$radius!,
    :$page!,
    ) is export {
    # a hex wheel of different-colored triangles centered
    # on the circle defined with the inputs

# TODO

    #$page.graphics: {
    $page.gfx: {
        .Save;
        # clip to a circle
        draw-circle $cx, $cy, $radius, :$page, :clip;

        my $cnum = 0;
        #my $stroke-color = color Black;
        my $stroke-color = color White;
        for 0..^6 {
            my $angle = $_ * 60;
            ++$cnum; # color number in %colors
            my $fill-color = %colors{$cnum};
            draw-hex-wedge :$cx, :$cy, :height($radius), :$angle, :stroke,
                           :fill, :$fill-color, :$stroke-color, :$page;
        }
        .Restore;
    }
} # sub draw-color-wheel(

sub draw-hex-wedge(
    :$cx!, :$cy!,
    :$height!, # apex at cx, ch, height is perpendicular at the base
    :$angle!,  # degrees ccw from 3 o'clock
    :$fill,
    :$stroke,
    :$fill-color   = [1],
    :$stroke-color = [0],
    :$page!,
    ) is export {
    #
    #          0
    #         /|\ equilateral triangle
    #        / | \ c
    #       /  |h \ 60 deg
    #    1 /---+---\ 2      given: h, angles 1 and 2 60 degrees each
    #        a   a
    #                    h/a = tan 60 deg
    #                    a   = h / tan 60
    #
    my $a = $height / tan(deg2rad(60));
    # point 0 is $cx,$cy --> 0, 0
    # rotate as desired by $angle
    # draw the triangle

    #my $g = $page.graphics;
    my $g = $page.gfx;
    $g.Save;
    $g.transform :translate($cx,$cy);
    $g.transform :rotate(deg2rad($angle));
    $g.LineWidth = 0;
    $g.FillColor = color $fill-color;
    $g.StrokeColor = color $stroke-color;
    $g.MoveTo: -$a, -$height;
    $g.LineTo: +$a, -$height;
    $g.LineTo:   0,   0;
    $g.ClosePath;
    if $fill and $stroke {
        $g.FillStroke;
    }
    elsif $fill {
        $g.Fill;
    }
    elsif $stroke {
        $g.Stroke;
    }
    $g.Restore;

    =begin comment
    $page.graphics: {
        .Save;
        .transform :translate($cx,$cy);
        .transform :rotate(deg2rad($angle));
        .LineWidth = 0;
        .FillColor = color $fill-color;
        .StrokeColor = color $stroke-color;
        .MoveTo: -$a, -$height;
        .LineTo: +$a, -$height;
        .LineTo:   0,   0;
        .ClosePath;
        if $fill and $stroke {
            .FillStroke;
        }
        elsif $fill {
            .Fill;
        }
        elsif $stroke {
            .Stroke;
        }
        .Restore;
    }
    =end comment
} # sub draw-hex-wedge(

sub simple-clip1(
    :$page!,
    ) is export {

    # draw a local circle for clipping
    # draw a local star overflowing the circle
    
} # sub simple-clip(
