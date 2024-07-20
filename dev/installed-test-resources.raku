#!/usr/bin/env raku

use FreeFont;
use FreeFont::Resources;

my %h = get-resources-hash;

for %h.kv -> $k, $v {
    say "$k => $v";
}
