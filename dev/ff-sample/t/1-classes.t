use Test;

use lib "./lib";

use FF;
use FF::Classes;

my $o;
my $number  = 1;
my $fontobj = 1;

lives-ok {
    $o = FF.new;
}

lives-ok {
    $o = FontClass.new: :$number, :$fontobj;
}

lives-ok {
    $o = DocFont.new;
}

done-testing;

