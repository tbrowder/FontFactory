use Test;

use QueryOS;
use File::Temp;

my $debug = 0;

my $os = OS.new;

use FreeFont;
use FreeFont::Utils;
use FreeFont::X::FontHashes;
use FreeFont::Classes;

my $ff = FreeFont.new;

my $n = "FreeSerif";
my $b = "FreeSerif.otf";
my $f = $ff.get-font: "t12d5";

=begin comment
say $f.name:    # OUTPUT: «Free Serif␤»
say $f.size;    # OUTPUT: «12.5␤»
say $f.file;    # OUTPUT: «/usr/share/fonts/opentype/freefont/FreeSerif.otf␤»
say $f.alias;   # OUTPUT: «Times␤»
say $f.license; # OUTPUT: «GNU GPL V3␤»
=end comment

is $f.name, "$n", "is name: '$n'";
is $f.size, 12.5, "is size: 12.5";
is $f.alias, "Times", "alias: Times";
is $f.license, "GNU GPL V3", "license: 'GNU GPL V3'";
is $f.basename, "$b", "basename: '$b'";



done-testing;

