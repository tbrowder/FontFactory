use Test;

use File::Temp;

use FreeFont::Resources;

my $orig-text = "some text";
my $tfil = "text.txt";

my $tmpdir = tempdir;

spurt-file  $orig-text, :basename($tfil), :dir($tmpdir);
my $copy-text = slurp-file "$tmpdir/$tfil";
is $copy-text, $orig-text;

done-testing;
