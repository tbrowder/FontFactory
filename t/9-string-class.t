use Test;

use FontFactory;
use FontFactory::Classes;
#use FontFactory::X::FontHashes;

my $ff = FontFactory.new;
my $df = $ff.get-font: 1, 12;

is $df.size, 12;

my $text = "To Wit, You See";
my $o = $df.string: $text;
is $o.text, $text;

# TODO use a text box to check output from FontFactory
#      a simple bbox should work

done-testing;

