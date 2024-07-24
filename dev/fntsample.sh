#!/bin/bash

if [[ -z "$1" ]]; then
    echo help follows
    exit
fi

FDIR=../resources/fonts
#FDIR=/usr/share/fonts/opentype/freefont
FFILE1=$FDIR/CMC7.ttf
FFILE2=$FDIR/GnuMICR.otf
FFILE3=$FDIR/micrenc.ttf

#FFILE=$FDIR/FreeSerif.otf
OFILE=FreeSeri.pdf
OFILE1=CMC7.ttf.pdf
OFILE2=GnuMICR.otf.pdf
OFILE3=micrenc.ttf.pdf
RANGE=1-300

fntsample -i $RANGE -f $FFILE3 -o $OFILE3

echo "See output file '$OFILE3'"

exit

fntsample -f $FFILE
Usage: fntsample [ OPTIONS ] -f FONT-FILE -o OUTPUT-FILE
       fntsample -h
exit

Usage: fntsample [ OPTIONS ] -f FONT-FILE -o OUTPUT-FILE
       fntsample -h

  --include-range,     -i RANGE        Show characters in RANGE

Options:
  --blocks-file,       -b BLOCKS-FILE  Read Unicode blocks information from BLOCKS-FILE
  --font-file,         -f FONT-FILE    Create samples of FONT-FILE
  --font-index,        -n IDX          Font index in FONT-FILE
  --output-file,       -o OUTPUT-FILE  Save samples to OUTPUT-FILE
  --help,              -h              Show this information message and exit
  --other-font-file,   -d OTHER-FONT   Compare FONT-FILE with OTHER-FONT and highlight added glyphs
  --other-index,       -m IDX          Font index in OTHER-FONT
  --postscript-output, -s              Use PostScript format for output instead of PDF
  --svg,               -g              Use SVG format for output
  --print-outline,     -l              Print document outlines data to standard output
  --write-outline,     -w              Write document outlines (only in PDF output)
  --no-embed,          -e              Don't embed the font in the output file, draw the glyphs instead
  --use-pango          -p              Use Pango for drawing glyph cells
  --include-range,     -i RANGE        Show characters in RANGE
  --exclude-range,     -x RANGE        Do not show characters in RANGE
  --style,             -t "STYLE: VAL" Set STYLE to value VAL

Supported styles (and default values):
	header-font (Sans Bold 12)
	font-name-font (Serif Bold 12)
	table-numbers-font (Sans 10)
	cell-numbers-font (Mono 8)
