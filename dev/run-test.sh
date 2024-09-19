#!/usr/bin/bash

# raku I --doc=Markdown lib/FontFactory/Classes.rakumod > DocFontClass.md
# time raku -I. t/0*t
time zef install . --debug --serial --/test-depends
