use Test;

use FreeFont;
use FreeFont::Classes;
#use FreeFont::X::FontHashes;

my $ff = FreeFont.new;
my $df = $ff.get-font: 1, 12;

is $df.size, 12;

my $text = "To Wit, You See";
my $o = $df.string: $text;
is $o.text, $text;

# TODO use a text box to check output from FreeFont
#      a simple bbox should work

done-testing;

