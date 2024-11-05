use Test;

my @modules = <
Args
FontClasses
OtherClasses
Config
Resources
Roles
PageProcs
Utils
PodUtils
FontUtils
BuildUtils
>;

# use FontFactory;
# FontUtils; # to become its own repo later
# BuildUtils; # to be removed

plan @modules.elems + 1;
my $mod = "FontFactory";

use-ok "$mod", "Module $mod can be used";
for @modules {
    use-ok "$mod::<$_>", "Module $_ can be used";
}

