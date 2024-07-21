#!/usr/bin/env raku

use Abbreviations;

my @w = <
Se
SeB
SeI
SeBI
Sa
Sa
SaO
SaBO
M
MBO
M
MOb
>;

my @a = abbrev @w;
.say for @a.sort;
