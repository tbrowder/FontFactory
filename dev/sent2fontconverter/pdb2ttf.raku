#!/bin/env raku

use Proc::Easier;

if not @*ARGS.elems {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <font file to be converted, with correct suffix>

    Converts fonts between PostScript and TTF formats:

      .pfa => .ttf
      .pfb => .ttf
      .ttf => .t1 + .afm

     Requires Linux programs: 'fontforge', 'pfbtopfa', 'pdffonts', 'pf2afm', 'printafm', and 'ttf2ufm'.

}

=begin comment

# convert TTF fonts to PostScript using ttf2ufm


# convert PostScript fonts to TTF using fontforge

12.1. A simple example
Suppose you have a Type1 PostScript font (a pfb/afm combination) and you would like to convert it into a TrueType font. What would a script look like that could do this?

If you were doing this with the UI you would first File->Open the font and then File->Generate a truetype font. You do essentially the same thing when writing a script:

12.1.1. Initial Solution
Open($1)
Generate($1:r + ".ttf")
There is usually a scripting function with the same name as a menu command (well, the same as the English name of the menu command).

‘$1’ is magic. It means the first argument passed to the script.

‘$1:r + “.ttf” ‘ is even more complicated magic. It means: ‘take the first argument ($1) and remove the extension (which is probably “.pfb”) and then append the string “.ttf” to the filename.’

The Generate scripting command decides what type of font to generate depending on the extension of the filename you give it. Here we give it an extension of “ttf” which means truetype.

Note that I make no attempt to load an afm file. That’s because the Open command will do this automagically if it is in the same directory as the pfb.

12.1.2. Real World Considerations
So that’s what the script looks like. To be useful it should probably live in a file of its own. So create a file called “convert.pe” and store the above script in it.

But to be even more useful you should add a comment line to the beginning of the script (a comment line is one that starts with the ‘#’ character:

#!/usr/local/bin/fontforge
Open($1)
Generate($1:r + ".ttf")
Having done that type:

$ chmod +x convert.pe
This comment is not important to fontforge, but it is meaningful to the unix shell, as we will see in the next section.

12.1.3. Invoking a script and passing it arguments
Ok, now we’ve got basic script. How do we use it?

Well we can pass it to FontForge directly by typing

$ fontforge -script convert.pe foo.pfb
But if you added the comment above you can also type:

$ convert.pe foo.pfb
And the shell knows to call fontforge to process the script.

=end comment
