use Test;

use FreeFont;

my $ff = FreeFont.new;
my $name = "Free Sans";

my $f = $ff.get-font: $name, :size(12.0);
is $f.size, 12.0;

done-testing;
