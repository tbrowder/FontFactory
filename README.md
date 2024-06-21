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
/usr/share/fonts/opentype/
say $f.alias; # OUTPUT:
Times
```

DESCRIPTION
===========

**FreeFont** is a package that provides easy handling of the GNU FreeFont set of OpenType fonts which closely match the classic Adobe Type 1 free fonts shown in the following table. Unlike the original Adobe fonts, these fonts also include thousands of Unicode characters. The fonts are also among the few, freely-available fonts that have Type 1 kerning.

Note the *Code* and *Code2* columns. Each row contains equivalent code you may use to select the FreeFont face. You can also use the complete name (with or without spaces) if desired.

<table class="pod-table">
<thead><tr>
<th>Name</th> <th>Code</th> <th>Code2</th> <th>Adobe Type 1</th>
</tr></thead>
<tbody>
<tr> <td>Free Serif</td> <td>se</td> <td>t</td> <td>Times</td> </tr> <tr> <td>Free Serif Bold</td> <td>seb</td> <td>tb</td> <td>Times Bold</td> </tr> <tr> <td>Free Serif Italic</td> <td>sei</td> <td>ti</td> <td>Times Italic</td> </tr> <tr> <td>Free Serif Bold Italic</td> <td>sebi</td> <td>tbi</td> <td>Times Bold Italic</td> </tr> <tr> <td>Free Sans</td> <td>sa</td> <td>h</td> <td>Helvetica</td> </tr> <tr> <td>Free Sans Bold</td> <td>sab</td> <td>hb</td> <td>Helvetica Bold</td> </tr> <tr> <td>Free Sans Oblique</td> <td>sao</td> <td>ho</td> <td>Helvetica Oblique</td> </tr> <tr> <td>Free Sans Bold Oblique</td> <td>sabo</td> <td>hbo</td> <td>Helvetica Bold Oblique</td> </tr> <tr> <td>Free Mono</td> <td>m</td> <td>c</td> <td>Courier</td> </tr> <tr> <td>Free Mono Bold</td> <td>mb</td> <td>cb</td> <td>Courier Bold</td> </tr> <tr> <td>Free Mono Oblique</td> <td>mo</td> <td>co</td> <td>Courier Oblique</td> </tr> <tr> <td>Free Mono Bold Oblique</td> <td>mbo</td> <td>cbo</td> <td>Courier Bold Oblique</td> </tr>
</tbody>
</table>

AUTHOR
======

Tom Browder <tbrowder@acm.org>

COPYRIGHT AND LICENSE
=====================

© 2024 Tom Browder

This library is free software; you may redistribute it or modify it under the Artistic License 2.0.

