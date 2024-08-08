#!/usr/bin/env raku

use lib "../lib";
use FontFactory::X::FontHashes;

%code = %FontFactory::X::FontHashes::code;

say %code.gist;
