[![Actions Status](https://github.com/tbrowder/FreeFont/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/FreeFont/actions) [![Actions Status](https://github.com/tbrowder/FreeFont/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/FreeFont/actions) [![Actions Status](https://github.com/tbrowder/FreeFont/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/FreeFont/actions)

NAME
====

**FreeFont** - Provides a convenience class to ease FreeFont font handling in different faces and sizes

SYNOPSIS
========

```raku
use FreeFont;
my $ff = FreeFont.new;
my $f = $ff.get-font: t12d5;
say $f.name:  # OUTPUT:
FreeSerif
say $f.size;  # OUTPUT:
12.5
say $f.file;  # OUTPUT:
/usr/share/fonts/free/..
say $f.alias; # OUTPUT:
Times-Roman
```

DESCRIPTION
===========

**FreeFont** is a package that provides easy handling of the GNU FreeFont set of OpenType fonts which closely match the classic Adobe Type 1 free fonts shown in the following table. Unlike the original Adobe fonts, these fonts also include thousands of Unicode characters. The fonts are also among the few, freely-available fonts that have Type 1 kerning.

<table class="pod-table">
<thead><tr>
<th>Name</th> <th>Code</th> <th>Adobe Alias</th>
</tr></thead>
<tbody>
<tr> <td>FreeSerif</td> <td>t</td> <td>Times</td> </tr> <tr> <td>FreeSerifBold</td> <td>tb</td> <td>Times Bold</td> </tr> <tr> <td>FreeSerifItalic</td> <td>ti</td> <td>Times Italic</td> </tr> <tr> <td>FreeSerifBoldItalic</td> <td>tbi</td> <td>Times Bold Italic</td> </tr> <tr> <td>FreeSans</td> <td>h</td> <td>Helvetica</td> </tr> <tr> <td>FreeSansBold</td> <td>hb</td> <td>Helvetica Bold</td> </tr> <tr> <td>FreeSansOblique</td> <td>ho</td> <td>Helvetica Oblique</td> </tr> <tr> <td>FreeSansBoldOblique</td> <td>ubo</td> <td>Helvetica Bold Oblique</td> </tr> <tr> <td>FreeMono</td> <td>c</td> <td>Courier</td> </tr> <tr> <td>FreeMonoBold</td> <td>cb</td> <td>Courier Bold</td> </tr> <tr> <td>FreeMonoOblique</td> <td>co</td> <td>Courier Oblique</td> </tr> <tr> <td>FreeMonoBoldOblique</td> <td>cbo</td> <td>Courier Bold Oblique</td> </tr>
</tbody>
</table>

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2024 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

