#!/usr/bin/env raku

use FontFactory;
use FontFactory::Resources;

if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go

    Used to prove the META file MUST have resources listed
    to use them WHEN it is installed by zef.

    Procedures:
    + Insure this repo is committed BEFORE testing
    + Delete the data in META6.json 'resources'
    + Install this repo locally: 
          cd ..; zef install . --debug --force-install
    + Return to this 'dev' dir
    + Execute this program:
          ./inst*


    HERE
    exit;
}

my %h = get-resources-hash;

my @keys = %h.keys.sort;
unless @keys.elems {
    print qq:to/HERE/;
    WARNING: The installed module has NO resources available.
    Ensure the META6.json 'resources' lists all desired
      items to access by the installed module
    HERE
    exit;
}

print qq:to/HERE/;
The following resources are available from the installed
'resources' directory:
HERE

for @keys -> $k {
    my $v = %h{$k};
    say "  '$k' => '$v'";
}
