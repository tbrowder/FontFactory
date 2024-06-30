unit module FreeFont::BuildUtils;

use PDF::Font::Loader :load-font;
use Text::Utils :split-line;

use FreeFont::X::FontHashes;
use FreeFont::Utils;

sub find-freefont(
    $number,
) is export {
    # return path to the file
    my ($path, $nam);
    $nam = %FreeFont::X::FontHashes::number{$number}<shortname>;
    if $nam.starts-with("m") {
        # it should be in $HOME/.FreeFont/fonts
        $path = "%*ENV<HOME>/.FreeFont/fonts/micrenc.ttf";
        return $path;
    }

    my ($fam, $wgt, $slnt) = 0, 0, 0;

    # what family
    if $nam.contains<sans> {
        $fam = "FreeSans"
    }
    if $nam.contains<serif> {
        $fam = "FreeSerif"
    }
    if $nam.contains<mono> {
        $fam = "FreeMono"
    }
    # what weight
    if $nam.contains<bold> {
        $wgt = "Bold"
    }
    # what slant
    if $nam.contains<italic> {
        $slnt = "Italic"
    }
    if $nam.contains<oblique> {
        $slnt = "Oblique"
    }

    # assemble the input to ;find-font
    my $query = "";
    $query = ":family<{$fam}>";
    if $wgt {
        $query ~= " :weight<{$wgt}>";
    }
    if $slnt {
        $query ~= " :slant<{$slnt}>";
    }

    # make the query
    $path = locate-font $query;

}
