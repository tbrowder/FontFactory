[![Actions Status](https://github.com/tbrowder/FreeFont/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/FreeFont/actions) [![Actions Status](https://github.com/tbrowder/FreeFont/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/FreeFont/actions) [![Actions Status](https://github.com/tbrowder/FreeFont/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/FreeFont/actions)

NAME
====

**FreeFont** - Provides convenience classes to ease GNU FreeFont font handling in different faces and sizes.

**NOTE**: The intent is for this module to work on Linux, MacOS, and Windows. Please file an issue if you need it on your OS and it is not working for you.

SYNOPSIS
========

```raku
use FreeFont;
my $ff = FreeFont.new;
# get a DocFont object for use with PDF documents
my $f1 = $ff.get-font: "t12d5";
say $f1.name:    # OUTPUT: «Free Serif␤»
say $f1.size;    # OUTPUT: «12.5␤»
say $f1.file;    # OUTPUT: «/usr/share/fonts/opentype/freefont/FreeSerif.otf␤»
say $f1.alias;   # OUTPUT: «Times␤»
say $f1.license; # OUTPUT: «GNU GPL V3␤»
```

Installation requirements
=========================

The following system packages need to be installed to use all the features of this module.

  * The FontConfig library

    On Debian:

        $ sudo aptitude install fontconfig

    On MacOS:

        $ brew install fontconfig

    On Windows:

        $ choco install fontconfig # if available

  * The FreeFont font files

    On Debian:

        $ sudo aptitude install fonts-freefont-otf

    On MacOS:

        $ brew install --cask font-freefont

    On Windows:

    If available:

        $ choco install font-freefont

    Alternatively:

        $ choco install wget
        # The 'zef install' process will download and install the FreeFont files.

On other systems the files may be downloaded from [https://ftp.gnu.org/gnu/freefont](https://ftp.gnu.org/gnu/freefont) and installed in any desired place. The paths to the installed files should then be entered manually in the `$HOME/.FreeFont/Config.yml` file which is created upon installation. That file should look like this (replace the '?' with the full path to the '.otf' file):

    # Basename              : Path
    FreeSerif.otf           : ?
    FreeSerifBold.otf       : ?
    FreeSerifItalic.otf     : ?
    FreeSerifBoldItalic.otf : ?
    FreeSans.otf            : ?
    FreeSansBold.otf        : ?
    FreeSansOblique.otf     : ?
    FreeSansBoldOblique.otf : ?
    FreeMono.otf            : ?
    FreeMonoBold.otf        : ?
    FreeMonoOblique.otf     : ?
    FreeMonoBoldOblique.otf : ?
    micrenc.ttf             : /home/usr/.FreeFont/fonts/micrenc.ttf
    GnuMICR.otf             : /home/usr/.FreeFont/fonts/GnuMICR.otf
    CMC7.ttf                : /home/usr/.FreeFont/fonts/CMC7.ttf

DESCRIPTION
===========

**FreeFont** is a package that provides easy handling of the GNU FreeFont set of OpenType fonts which descended from the classic Adobe Type 1 free fonts shown in Table 2 below. Unlike the original Adobe fonts, these fonts also include thousands of Unicode characters. The fonts are also among the few, freely-available fonts that have Type 1 kerning.

See [https://www.gnu.org/software/freefont/sources/](https://www.gnu.org/software/freefont/sources/) for much more information on the sources and Unicode coverage of the GNU FreeFont collection.

Note the *Code* and *Code2* columns. Each row contains equivalent code you may use to select the FreeFont face. You can also use the reference number.

Table 1
-------

<table class="pod-table">
<caption>The GNU FreeFont Collection</caption>
<thead><tr>
<th>FreeFont Name</th> <th>Code</th> <th>Code2</th> <th>Reference No.</th>
</tr></thead>
<tbody>
<tr> <td>Free Serif</td> <td>se</td> <td>t</td> <td>1</td> </tr> <tr> <td>Free Serif Bold</td> <td>seb</td> <td>tb</td> <td>2</td> </tr> <tr> <td>Free Serif Italic</td> <td>sei</td> <td>ti</td> <td>3</td> </tr> <tr> <td>Free Serif Bold Italic</td> <td>sebi</td> <td>tbi</td> <td>4</td> </tr> <tr> <td>Free Sans</td> <td>sa</td> <td>h</td> <td>5</td> </tr> <tr> <td>Free Sans Bold</td> <td>sab</td> <td>hb</td> <td>6</td> </tr> <tr> <td>Free Sans Oblique</td> <td>sao</td> <td>ho</td> <td>7</td> </tr> <tr> <td>Free Sans Bold Oblique</td> <td>sabo</td> <td>hbo</td> <td>8</td> </tr> <tr> <td>Free Mono</td> <td>m</td> <td>c</td> <td>9</td> </tr> <tr> <td>Free Mono Bold</td> <td>mb</td> <td>cb</td> <td>10</td> </tr> <tr> <td>Free Mono Oblique</td> <td>mo</td> <td>co</td> <td>11</td> </tr> <tr> <td>Free Mono Bold Oblique</td> <td>mbo</td> <td>cbo</td> <td>12</td> </tr> <tr> <td>MICRE</td> <td>mi</td> <td>mi</td> <td>13 (not a FreeFont)</td> </tr> <tr> <td>GnuMICR</td> <td>mi2</td> <td>mi2</td> <td>14 (not a FreeFont)</td> </tr> <tr> <td>CMC7</td> <td>c7</td> <td>c7</td> <td>15 (not a FreeFont)</td> </tr>
</tbody>
</table>

Table 2
-------

<table class="pod-table">
<caption>The Equivalent Adobe Type 1 Fonts</caption>
<thead><tr>
<th>Adobe Type 1 Name</th> <th>Code</th> <th>Code2</th> <th>Reference No.</th>
</tr></thead>
<tbody>
<tr> <td>Times</td> <td>se</td> <td>t</td> <td>1</td> </tr> <tr> <td>Times Bold</td> <td>seb</td> <td>tb</td> <td>2</td> </tr> <tr> <td>Times Italic</td> <td>sei</td> <td>ti</td> <td>3</td> </tr> <tr> <td>Times Bold Italic</td> <td>sebi</td> <td>tbi</td> <td>4</td> </tr> <tr> <td>Helvetica</td> <td>sa</td> <td>h</td> <td>5</td> </tr> <tr> <td>Helvetica Bold</td> <td>sab</td> <td>hb</td> <td>6</td> </tr> <tr> <td>Helvetica Oblique</td> <td>sao</td> <td>ho</td> <td>7</td> </tr> <tr> <td>Helvetica Bold Oblique</td> <td>sabo</td> <td>hbo</td> <td>8</td> </tr> <tr> <td>Courier</td> <td>m</td> <td>c</td> <td>9</td> </tr> <tr> <td>Courier Bold</td> <td>mb</td> <td>cb</td> <td>10</td> </tr> <tr> <td>Courier Oblique</td> <td>mo</td> <td>co</td> <td>11</td> </tr> <tr> <td>Courier Bold Oblique</td> <td>mbo</td> <td>cbo</td> <td>12</td> </tr> <tr> <td>MICRE</td> <td>mi</td> <td>mi</td> <td>13 (not a FreeFont)</td> </tr> <tr> <td>GnuMICR</td> <td>mi2</td> <td>mi2</td> <td>14 (not a FreeFont)</td> </tr> <tr> <td>CMC7</td> <td>c7</td> <td>c7</td> <td>15 (not a FreeFont)</td> </tr>
</tbody>
</table>

Notes on the three additional fonts
-----------------------------------

Each table above shows three more fonts that are included in the '/resources' directory, along with several other files, that will be installed into your '$HOME/.FreeFont/fonts' or '$HOME/.FreeFont/docs' directories, as appropriate.

The MICR fonts (more formally known as E13B) are designed to produce the machine-readable numbers found on bank checks in the US and Canada and other countries around the world, promarily in Asia.

An equivalent font, CMC7, is used in other countries, primarily South America and Europe.

### MICRE

That is a MICRE font in TrueType format ('.ttf'). The MICR Encoding font, used for bank checks, was obtained from [1001fonts.com](https://www.1001fonts.com/micr-encoding-font.html).

The downloaded file was named `micr-encoding.zip` (which was deleted after unzipping it). When file `micr-encoding.zip` was unzipped into an `unzipped` directory, the following files were found:

      '!DigitalGraphicLabs.html'
      '!license.txt'
      micrenc.ttf

The two files in single quotes were renamed to:

    DigitalGraphicLabs.html
    micrenc-license.txt

and all three files will be installed in your '$HOME/.FreeFont' directory.

The license basically says the font is free to use for non-commercial purposes. Consult the license carefully if you do intend to use it commercially.

### GnuMICR

This is a Gnu version of the MICRE font face, in OpenType format ('.otf'), which *can* be used commercially. See the GNU license in the *COPYING.txt* file in the '/resources' directory.

See many more details and supporting files at the author's site at [](https://sandeen.net/GnuMICR).

### CMC7

This is a free font designed by Harold Lohner, in 1998, and placed into the public domain by him. It was downloaded from [https://www.fonts4free.net/cmc-7-font.html](https://www.fonts4free.net/cmc-7-font.html). See more details and the license in the *CMC7.txt* file in the '/resources' directory.

The DocFont class
=================

The `$t12d5` object shown above in the *SYNOPSIS* section is actually a `DocFont` object that essentially pairs a `PDF::Font::Loader::FontObj` with a `size` attribute. That pairing, along with suitable naming of the object, can make it easier to manage font faces for complex documents as shown in a program constructing a simple PDF page (a copy is in this repository's 'examples' directory):

    #!/usr/bin/env raku
    use PDF::Lite;
    use PDF::Font::Loader :load-font;
    use FreeFont;
    use FreeFont::Classes;
    my $ff = FreeFont.new;
    my $t12d5 = $ff.get-font: "t12d5"; # FreeSerif (Times), 12.5 points
    my PDF::Lite $pdf .= new;
    $pdf.add-page.text: {
       .font = $t12d.font, $t12d.size; # <== .font, .size (the two required values)
       .text-position = [10, 600];
       .say: "Hello, World!";
    }
    $pdf.save-as: "ff-example.pdf";

AUTHOR
======

Tom Browder <tbrowder@acm.org>

Summary of FONTS COPYRIGHT and LICENSE
======================================

  * Gnu Free Fonts - GNU GENERAL PUBLIC LICENSE Version 3

    See */resources/GPL-VERSION3.txt* and more information at [https://www.gnu.org/software/freefont/](https://www.gnu.org/software/freefont/).

  * MICRE - DISTRIBUTED AS FREEWARE

    See */resources/micrenc-license.txt*

  * GnuMICRE - GNU GENERAL PUBLIC LICENSE Version 2, June 1991

    See */resources/COPYING.txt*

  * CMC7 - Public Domain

    See */resources/CMC7.txt*

COPYRIGHT AND LICENSE
=====================

Copyright © 2024 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

