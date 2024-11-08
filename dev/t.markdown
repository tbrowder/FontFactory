TITLE
=====

GBUMC Name Tags: The Project

AUTHOR
======

Tom Browder

DATE
====

2024-09-16

Part A. Status as of Sunday, 2024-09-15
=======================================

I will continue to tweak the name tags, and welcome any suggested changes. I do plan to make the embellishment pattern (aka GBUMC logo) exactly the same as the one that appears on the bottom-right corner of today’s bulletin .

My purpose for producing the name tags
======================================

In my advanced age, it is getting harder to remember names. Seeing congregants with an easily-readable name tag helps recalling the name for use in conversation. My name tag design fits that requirement.

Importantly, it also identifies one as a GBUMC congregant and is very suitable for wear at any church-related event, particularly public events such as Trunk or Treat or other outreach events.

Unique features of my design
============================

1. Dimensions, text, colors, and embellishments are easily changed.

2. If printed correctly on two-sided paper, the same design (and names) appear even if it is flipped over as happens so often when one is wearing them.

3. They are cheap to produce: Clear plastic badge holders from Walmart (including our local "little" Walmart) or Amazon can be bought for 50 cents or less and they have pocket clips included.  Suitable lanyards are also inexpensive.

4. With the current size of them, eight name tags can printed per sheet of paper. (I know the church has a good color-capable printer.

5. They are easy to cut out and assemble.

6. Mistakes are readily corrected.

How I produce the name tags using a free program
================================================

I have created a free, publicly available (see details below), Raku computer language ([http://Raku.org](http://Raku.org)) program that creates the two-sided PDF sheet for US Letter paper in Portrait orientation. The program is command-line executed on computers running a GNU/Linux operating system (I use Debian). It should also run on a MacOS system when I eventually port the program to it using my wife's Mac (that is a low priority until users request it by filing an issue on GitHub OR emailing me).

Note the Mac system will have to have some Rakudo and other prerequisite programs installed (I have one to work with for my use, but check with your IT person for any computers on the church's private network).

It is also possible to port it to Windows, but that is not so easy given the weirdisms of the Windows OS preventing so many prerequistes from being ported to it.

The name tag program
====================

The only input required is a list of names in a plain text document such as a CSV file or a Windows Notepad file. That file is provided as the only input to the program, and the output is a single PDF document suitable for printing on almost any modern printer, or viewing in most modern web browsers.

The input file must be formatted according to these rules (see Notes):

  * one name per line

  * last-name first-name middle-name

Formatting Notes:
-----------------

  * names may be separated by spaces or commas

  * the first-name (along with any middle-name) will be printed on the first line of the name tag

  * the last-name will be printed on the second line of the name tag

Program
=======

The program source code is publicly available in the /dev directory of the FontFactory repository in my GitHub account (see [https://github.com/tbrowder/FontFactory](https://github.com/tbrowder/FontFactory)). The program file name is 'make-name-tags.raku'.

