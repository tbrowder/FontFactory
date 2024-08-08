use Test;

use QueryOS;
use PDF::Font::Loader;

use FontFactory;

my $debug = 0;

# TODO fix this:
# my $font = "FreeSerif";
# my $f = find-font :family($font);
# note "DEBUG: response from find-font: '$f'" if $debug;

my $os = OS.new;
if $os.is-windows {
    is 1, 1, "is Windows";
}
if $os.is-macos {
    is 1, 1, "is MacOS";
}
if $os.is-linux {
    is 1, 1, "is Linux";
}

my $ff = FontFactory.new;

done-testing;

=finish

my $name = "Free Sans";
my $f = $ff.get-font: $name, :size(12.0);
is $f.size, 12.0;

# TODO add tests

done-testing;
