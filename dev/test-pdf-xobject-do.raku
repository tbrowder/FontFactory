#!/usr/bin/env raku

use PDF::API6;
use PDF::Content;
use PDF::Content::XObject;
use PDF::Content::FontObj; # required with XObject
use PDF::Content::Color :rgb;
use PDF::Lite;

# Note the forms method saves time (and space) since the image is rendered only
# once! But one needs to organize things a bit to keep track of images
# in the XOject dictionary.

my PDF::Lite $pdf .= new;
my PDF::Lite::Page $page = $pdf.add-page;
$pdf.media-box = 0, 0, 8.5*72, 11*72;
my $pw = $pdf.media-box[2];
my $ph = $pdf.media-box[3];
my $cx = 0.5 * $pw;
my $cy1 = 0.25 * $ph;
my $cy2 = 0.75 * $ph;

my ($w, $h, $wscaled, $hscaled);

my $g = $page.gfx;
$g.Save;

my PDF::Content::XObject $png .= $g.open("./GBUMC-logo.png");
$w       = $png.width;
$h       = $png.height;
$wscaled = $w/30;
$hscaled = $h/30;

#=begin comment
# forms method
my PDF::Content::XObject-Form $form = $g.xobject-form(:BBox[0, 0, $wscaled, $hscaled]);
my $fg = $form.gfx;
$fg.tag: 'P', {
    .FillColor = color White;
    .Rectangle: |$form<BBox>;
    .paint: :fill;
}

$g.do: $form, :position($cx, $cy1), :width($wscaled), :height($hscaled), 
              :valign<center>, :align<center>;
#=end comment

=begin comment
# image method
$g.do: $png, :position($cx, $cy2), :width($wscaled), :height($hscaled), :valign<center>, :align<center>;
=end comment

$g.Restore;


my $ofil = "do-test.pdf";
$pdf.save-as: $ofil;

say "See file '$ofil'";
