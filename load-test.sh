#!/usr/bin/bash

#raku I --doc=Markdown lib/FontFactory/Classes.rakumod > DocFontClass.md
raku -I. t/0*t
