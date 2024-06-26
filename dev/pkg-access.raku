#!/usr/bin/env raku

use lib "../lib";
use FreeFont::X::FontHashes;

my %code = %FreeFont::X::FontHashes::code;

say %code.gist;
