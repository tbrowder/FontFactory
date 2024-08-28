unit module NameTags;

use PDF::API6;
use PDF::Lite;
use PDF::Content::Color :ColorName, :color;

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
my $hm = 0.5*72;  # horizontal margins
my $vm = 0.75*72; # vertical margins

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

#==== subroutines
sub get-dims-hash(--> Hash) is export {
    %dims;
}

sub make-front-side(
    @p,       # list of 8 or less names for a page
    :$page,
    :$debug,
) is export {
    my @r = @p;
    my (@c, $n);
    while @r.elems {
        # row 1
        @c = @r.splice(0,2);
        $n = @c.elems;
        # badge center points depend on number of names and
        # row number
        for @c {
        }


        last unless @r.elems;

        # row 2
        @c = @r.splice(0,2);
        $n = @c.elems;
        last unless @r.elems;

        # row 3
        @c = @r.splice(0,2);
        $n = @c.elems;
        last unless @r.elems;

        # row 4
        @c = @r.splice(0,2);
        $n = @c.elems;
    }
}

sub make-back-side(
    @p,       # list of 8 or less names for a page
    :$page,
    :$debug,
) is export {
    my @r = @p;
    my (@c, $n);
    while @r.elems {
        # row 1
        @c = @r.splice(0,2);
        $n = @c.elems;
        last unless @r.elems;

        # row 2
        @c = @r.splice(0,2);
        $n = @c.elems;
        last unless @r.elems;

        # row 3
        @c = @r.splice(0,2);
        $n = @c.elems;
        last unless @r.elems;

        # row 4
        @c = @r.splice(0,2);
        $n = @c.elems;
    }
}

sub make-label(
    :$text = "<text>",
    :$width,      # points
    :$height,     # points
    :$cx!, :$cy!, # points
    :$page!,
    # default color for top portion is blue

    # translate to the center
) is export {
}

sub make-cross(
    :$width,      # points
    :$height,     # points
    :$cx!, :$cy!, # points
    :$page!,
    # default color is white
) is export {
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
