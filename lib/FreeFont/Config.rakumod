unit module FreeFont::Config;

use QueryOS;
use FreeFont::X::FontHashes;

my $os = OS.new;

# The subs and data in this file are
# used to construct all the required
# data in the $HOME/.FreeFont/ 
# directory.

# The installed GNU Free Fonts fonts are
# contained in different directories:

my $Ld = 0;
my $Md = 0;
my $Wd = 0;
