unit module NameTags;

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
        make-label($nam2, :width($bw), :height($bh), :cx($hmid2), :$cy, :$page) if $nam2;
    }
}

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


    # the outline
    $page.graphics: {
        .Save;
        # translate to top-left corner
        my $ulx = $cx - 0.5 * $width;
        my $uly = $cy + 0.5 * $height;

        .transform: :translate($ulx, $uly);
        .StrokeColor = color Black;
        #.FillColor = rgb(0, 0, 0); # color Black
        .LineWidth = 0;
        .Rectangle(0, -$height, $width, $height);
        .Stroke; #paint: :fill, :stroke;
        .Restore;
    }

    # the blue part
    $page.graphics: {
        .Save;
        # translate to top-left corner
        my $ulx = $cx - 0.5 * $width;
        my $uly = $cy + 0.5 * $height;
        .transform: :translate($ulx, $uly);
        .FillColor = color 0.8; # light gray
        #.FillColor = color Navy; #rgb(0, 0, 0.5);
        #.FillColor = color Blue; #rgb(0, 0, 1);
        .LineWidth = 0;
        # the height is part of label $height
        my $bh = $height * 0.3;
        .Rectangle(0, -$bh, $width, $bh);
        .paint: :fill, :stroke;
        .Restore;
    }

    # gbumc text in the blue part
    $page.graphics: {
        .Save;
        my $gb = "GBUMC";
        my $tx = $cx;
        my $ty = $cy + ($height * 0.35);
        .transform: :translate($tx, $ty); # where $x/$y is the desired reference point
        #.text-transform: :translate($tx, $ty);
        .FillColor = color White; #rgb(0, 0, 0); # color Black
        .font = %fonts<hb>, #.core-font('HelveticaBold'),
                 $line1size; # the size
        .print: $gb, :align<center>, :valign<center>;
        .Restore;
    }

    #make-cross(:diam(15), :thick(10), :width(25), :height(25), :cx(0), :cy(0), :$page, :$debug);

    my @w = $text.words;
    my $last = @w.shift;
    my $first = @w.shift;
    my $middle = @w.elems ?? @w.shift !! 0;
    $first = "$first $middle" if $middle;
    say "first: $first" if $debug;
    say "last: $last" if $debug;

    # line 2 (first name)
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
        .FillColor = color Black; #rgb(0, 0, 0); # color Black
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
        .FillColor = color Black; #rgb(0, 0, 0); # color Black
        .font = %fonts<hb>, #.core-font('HelveticaBold'),
                 $line3size; # the size
        .print: $last, :align<center>, :valign<center>;
        .Restore;
    }

}

sub make-cross(
    # overall dia
    :$diam!,
    :$thick!,
    :$width!,      # points
    :$height!,     # points
    :$cx!, :$cy!, # points
    :$page!,
    :$debug,
    # default color is white
) is export {

    # initial model will be a hollow circle with symmetrical spokes in
    # shape of a cross, with a rose background color to simulate
    # GBUMC's rose window
    my $radius = $diam*0.5;

    # outer filled with white
    draw-circle $cx, $cy, $radius, :color([0]), :$page;
    # inner filled with rose
    draw-circle $cx, $cy, $radius, :color([1]), :$page;

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
}

sub draw-circle(
    $x, $y, $r,
    :$page!,
    :$fill = True,
    :$color = [1], # white
    :$linewidth = 0
) is export {
    $page.graphics: {
        .Save;
        .setline: :$linewidth, :$color;
        # from stack overflow: copyright 2022 by Spencer Mortenson
        .transform: :translate[$x, $y];
        constant c = 0.551915024495;
        .MoveTo: 0*$r, 1*$r; # top of the circle
        # use four curves
        .CurveTo:  c*$r, 1*$r,  1*$r, c*$r,  1*$r, 0*$r;
        .CurveTo:  1*$r,-c*$r,  c*$r,-1*$r,  0*$r,-1*$r;
        .CurveTo: -c*$r,-1*$r, -1*$r,-c*$r, -1*$r, 0*$r;
        .CurveTo: -1*$r, c*$r, -c*$r, 1*$r,  0*$r, 1*$r;
        .ClosePath;
        .Fill;
        .Restore;
    }
}

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
}
