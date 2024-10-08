unit module FontFactory::PageProcs;

# copied from FontFactory/lib/PageProcs.rakumod; 2024-07-23
use PDF::API6;
use PDF::Lite;
#use PDF::Font::Loader :load-font;
use PDF::Content::FontObj;
use PDF::Content::Page :PageSizes;
use PDF::Content::Color :ColorName, :rgb;

# Routines to create text and graphics blocks on
# a PDF::Content::Page (or a PDF::Lite::Page?).
sub get-media(
    Str $media where { /:i [Letter|A4]/ },
    :$debug,
    --> Array
) is export {
    # returns an array of (xxx. lly, urx. ury)
    my @arr = [0, 0, 612, 792]; # Letter
    with $media {
        when /:i letter/ {
            @arr = [0, 0, 612, 792];
        }
        when /:i a4/ {
            @arr = [0, 0, 595, 842];
        }
        default {
            # Letter
            @arr = [0, 0, 612, 792];
        }
    }
    @arr
}

sub get-rgb(
    $color is copy,
    :$debug,
    --> Array
) is export {
    with $color {
        # See PDF::Content::Color for the 20 known colors
        # We can add more if need be
        when /:i (aqua    | black   |
                  blue    | fuschia |
                  gray    | green   |
                  lime    | maroon  |
                  navy    | olive   |
                  orange  | purple  |
                  red     | silver  |
                  teal    | white   |
                  yellow  | cyan    |
                  magenta | registration
                  ) / {
            $color = ~$0.tc;
        }
        default {
            $color = "Black";
        }
    }
    # $pdf.media-box = %(PageSizes.enums){$media};
    # Note we MUST coerce it to an Array
    @(%(ColorName.enums){$color});
}

# use: start-page :$page, :landscape(True), :inverted(False), :media<Letter>;
sub start-page(
    PDF::Content::Page :$page!,
    Bool :$landscape is copy = False,
    Bool :$inverted  is copy = False, # instead of "upside-down"
    :$media where { /:i [Letter|A4]/ } = "letter",
    :$debug,
) is export {

    # For this document, always use internal landscape, "right-side up"
    # i.e, NOT upside-down (inverted)

    # Set the media here
    with $media {
        when /:i letter/ {
            $page.media-box = get-media($media);
        }
        when /:i a4/ {
            $page.media-box = get-media($media);
        }
    }

    #$page.graphics: {
    $page.gfx: {
        # always save the CTM
        # BUT DON'T FORGET sub finish-page!
        #.Save;
        #===================================
        my ($w, $h);

        if $inverted {
            die q:to/HERE/;
            FATAL: The 'inverted' (upside-down) transformation is
                   not yet available (NYI).
            HERE
        }

        # Set the landscape if needed
        if $landscape {
            #    if not $upside-down {
            # Normal landscape

            # Translate from: lower-left corner to: lower-right corner
            # LLX, LLY -> URX, LLY
            .transform: :translate($page.media-box[2], $page.media-box[1]);


            # Rotate: left (ccw) 90 degrees
            .transform: :rotate(90 * pi/180); # left (ccw) 90 degrees

            #    for upside-down:
            #        MAKE ONE MORE TRANSLATION IN Y=0 AT TOP OF PAPER
            #        THEN Y DIMENS ARE NEGATIVE AFTER THAT
            #        LLX, LLY -> LLX, URY
            #    }

            # Finally, move the origin to the lower-right corner
            # TODO this may be a NO-OP
            if 1 { #not $debug {
                .transform: :translate(0, $page.media-box[2]);
            }
            else {
                note "DEBUG: NOT using possible NO-OP translation";
            }
        }

        $w = $page.media-box[3] - $page.media-box[1];
        $h = $page.media-box[2] - $page.media-box[0];
        if $debug {
            $*OUT.print: qq:to/HERE/;
            DEBUG: start-page:
              \$w = $w
              \$h = $h
              \$landscape = $landscape
            HERE
        }
    }
}

sub finish-page(
    PDF::Content::Page :$page!,
    :$debug,
) is export {
    $page.graphics: {
        .Restore;
    }
}

# use: put-text :$text, :$page, :$x-origin, :$y-origin, :$font, :$font-size,
#               :$align, :$valign, :$font-color;
sub put-text(
    :$text = "",
    PDF::Content::Page :$page!,
    :$x-origin!, :$y-origin!,
    :$font!,
    :$font-size is copy = 10,
    :$width, :$height,
    :$align is copy = "left", :$valign is copy = "bottom",
    :$font-color is copy = "black",
    :$debug,
) is export {
    $align  = "center";
    $valign = "center";
    my ($w, $h) = $width, $height;
    my PDF::Content::Text::Box $text-box;
    my @b = $text-box .= new: :$text, :$font, :$font-size, :$align, :$valign;
    # ^^^ note use of :$height # restricts the size of the box

    $page.graphics: {
        .Save;
        .SetStrokeRGB: get-rgb($font-color);
        .transform: :translate($x-origin, $y-origin);
        # put a text box inside
        .BeginText;
        #.text-position[$x-origin, $y-origin];
        .text-position[0, 0];
        .print: $text-box;
        .EndText;
        .Restore;
    }
    @b
}

# use: draw-box :$page, :$llx, :$lly, :$width, :$height, :$border-width,
#               :$border-color, :$fill-color;
sub draw-box(
    PDF::Content::Page :$page!,
    :$llx!, :$lly!, :$width!, :$height!,
    Bool :$inside = True,
    :$border-width is copy = 1.5,
    :$border-color = "Black",
    :$fill-color = "White",
    :$debug,
) is export {

   my ($w, $h, $bw) = $width, $height, $border-width;

    $page.graphics: {
        # Prepare the cell by filling with black then move inside
        # (or outside) by border width and fill with desired color
        .Save;
        .transform: :translate($llx, $lly); # lower-left corner

        # Fill cell with border color and clip to exclude color
        # outside (or inside) created by the borderwidth
        .SetFillRGB: get-rgb($border-color); # Black
         # rectangles start at their lower-left corner
         if $inside {
            .Rectangle: 0, 0, $w, $h;
         }
         else {
            .Rectangle: 0-$bw, 0-$bw, $w+2*$bw, $h+2*$bw;;
         }
        .ClosePath;
        .Clip;
        .Fill;

        # Fill cell with fill (background) color and clip it inside
        # (or outside) by the border width
        .SetFillRGB: get-rgb($fill-color); # White
        if $inside {
           .Rectangle: 0+$bw, 0+$bw, $w-2*$bw, $h-2*$bw;
        }
        else {
           .Rectangle: 0, 0, $w, $h;
        }
        .Clip;
        .Fill;

        .Restore;
    }
}
