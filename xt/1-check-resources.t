use Test;

use File::Find;
use JSON::Fast;

is 1, 0;

my $debug = 0;
# compare /resources and META6.json
my %m = from-json "META6.json".IO.slurp;

# the files in /resources WITHOUT 'resources' in their paths
my @mf = @(%m<resources>);
if $debug {
    .say for @mf.sort;
}

# the files in /resources WITH 'resources' in their paths
my @rf = find :dir("resources"), :type<file>;
if $debug {
    .say for @rf.sort;
}



=finish
