#!/usr/bin/env raku

use lib "../lib";
use FreeFont::X::FontHashes;

%code = %FreeFont::X::FontHashes::code;

say %code.gist;
