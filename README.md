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
<tr> <td>FreeSerif FreeSerifBold FreeSerifItalic FreeSerifBoldItalic</td> <td>t tb ti tbi</td> <td>Times Times Bold Times Italic Times Bold Italic</td> </tr> <tr> <td>FreeSans FreeSansBold FreeSansOblique FreeSansBoldOblique</td> <td>h hb ho ubo</td> <td>Helvetica Helvetica Bold Helvetica Oblique Helvetica Bold Oblique</td> </tr> <tr> <td>FreeMono FreeMonoBold FreeMonoOblique FreeMonoBoldOblique</td> <td>c cb co cbo</td> <td>Courier Courier Bold Courier Oblique Courier Bold Oblique</td> </tr>
</tbody>
</table>

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2024 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

