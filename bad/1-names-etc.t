use Test;

use FreeFont;
use FreeFont::BuildUtils;
use FreeFont::X::FontHashes;

my $ff = FreeFont.new;

my $name = "Free Sans";
my $f = $ff.get-font: $name, :size(12.0);
is $f.size, 12.0;

my %n = %FreeFont::X::FontHashes::number;
# TODO add tests

for %n.keys -> $n {
    my $nam = %n{$n}<shortname>;
    note "DEBUG: nam: $nam";
    note "DEBUG: early exit from tests":
    last;
    my $f = $ff.get-font: $nam, :size(12.0);
    is $f.size, 12.0;
    is $f.shortname, $nam, "shortname: '{$f.shortname}', nam: '$nam'";

}

done-testing;
