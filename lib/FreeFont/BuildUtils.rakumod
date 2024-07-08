unit module FreeFont::BuildUtils;

use PDF::Font::Loader :load-font;
use Text::Utils :split-line;
use YAMLish;

use FreeFont::X::FontHashes;
use FreeFont::Utils;

sub find-freefont(
    $number,
) is export {
    # return path to the file
    # use the font basename
    my ($path, $nam);
    $nam = %FreeFont::X::FontHashes::number{$number}<name>;
    # we need to add '.otf' or '.ttf'
    # to get the basename
    if $nam.starts-with("M") {
        # special case for this one,
        # basename is a bit different
        $nam = "micrenc.ttf";
    }
    else {
        # the GNU fonts just need proper
        # suffix
        $nam ~= ".otf";
    }

    # If the config.yml file exists, it
    # should already have the 15 paths
    # without using sub locate-font.

    my $config = "%*ENV<HOME>/.FreeFont/config.yml";
    if $config.IO.r {
        # read yml
        my $str  = $config.IO.slurp;
        my %conf = load-yaml $str;
        $path    = %conf{$nam};
    }
    else {
        # Make the query to sub
        # locate-font
        # in module FreeFont::Utils
        $path = locate-font $nam;
    }

    $path
} # sub find-freefont(
