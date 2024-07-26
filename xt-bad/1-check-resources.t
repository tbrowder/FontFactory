use Test;

use File::Find;
use JSON::Fast;

my $debug = 0;

# compare /resources and META6.json
my %m = from-json "META6.json".IO.slurp;

# the files in /resources WITHOUT 'resources' in their paths
my @mfils = @(%m<resources>);
my %mhash;
my $is-good = True; # assumption
for @mfils {
    my $b = $_.IO.basename;
    my $path = "resources/$_".IO;
    if %mhash{$b}:exists {
        # test failure
        $is-good = False;
    }
    else {
        %mhash{$b} = $path;
    }
}

if $debug {
    say "Files in \%meta<resources>:";
    say "  $_"  for @mfils.sort;
}

# the files in /resources WITH 'resources' in their paths
my @rfils = find :dir("resources"), :type<file>;
my %rhash;
for @rfils {
    my $b = $_.IO.basename;
    my $path = $_;
    if %rhash{$b}:exists {
        # test failure
        $is-good = False;
    }
    else {
        %rhash{$b} = $path;
    }
}

is $is-good, True;

my @mkeys = %mhash.keys.sort;
my @rkeys = %rhash.keys.sort;
is-deeply @mkeys, @rkeys;
my @mvals = %mhash.values.sort;
my @rvals = %rhash.values.sort;
is-deeply @mvals, @rvals;

#is-deeply %mhash, %rhash;

if $debug {
    say "Files in /resources:";
    say "  $_" for @rfils.sort;
}

# get the top-level dir 
my @rdirs = find :dir("resources"), :type<dir>;
if $debug {
    my $nrdirs = @rdirs.elems;
    if $nrdirs {
        say "Subdirectories in /resources:";
        say "  $_" for @rdirs.sort;
    }
    else {
        say "There are NO subdirectories in /resources";
    }
}

done-testing;

=finish
