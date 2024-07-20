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

my $f1 = $ff.get-font: "t12d5";

=begin comment
say $f1.name:    # OUTPUT: «Free Serif␤»
say $f1.size;    # OUTPUT: «12.5␤»
say $f1.file;    # OUTPUT: «/usr/share/fonts/opentype/freefont/FreeSerif.otf␤»
say $f1.alias;   # OUTPUT: «Times␤»
say $f1.license; # OUTPUT: «GNU GPL V3␤»
=end comment

is $f1.name, "FreeSerif", "is name: 'FreeSerif'";
is $f1.size, 12.5, "is size: 12.5";
is $f1.file, "/usr/share/fonts/opentype/freefont/FreeSerif.otf", "file: '.../FreeSerif.otf'";
is $f1.path, "/usr/share/fonts/opentype/freefont/FreeSerif.otf", "path: '.../FreeSerif.otf'";
is $f1.alias, "Times", "alias: Times";
is $f1.license, "GNU GPL V3", "license: 'GNU GPL V3'";
is $f1.basename, "FreeSerif.otf", "basename: 'FreeSerif.otf'";


done-testing;

