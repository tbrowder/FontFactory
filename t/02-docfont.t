use Test;

use FontFactory;
use FontFactory::DocFont;
use FontFactory::FF-Subs;
use FontFactory::DocFont::GChar;
use FontFactory::DocFont::DF-Subs;

my $ff = FontFactory.new;
isa-ok $ff, FontFactory;

my $df = $ff.get-docfont: "t/fonts/DejaVuSerif.ttf", 14;
isa-ok $df, FontFactory::DocFont;
is $df.size, 14;
is $df.name, "DejaVuSerif.ttf", "font file basenane";
is $df.postscript-name, "DejaVuSerif";
is $df.family-name, "DejaVu Serif";
is $df.has-kerning, True;
is $df.is-scalable, True;
is $df.units-per-EM, 2048;
is $df.is-sfnt, True;
is $df.is-bold, False;
is $df.is-italic, False;
is $df.font-format, "TrueType";
is $df.has-horizontal-metrics, True;
is $df.has-vertical-metrics, False;

my FontFactory::DocFont::GChar $c = $df.glyph: 'A';
isa-ok $c, FontFactory::DocFont::GChar;
is $c.Str, 'A';

my @gchars = get-gchars $df.face, "aB d";
for @gchars {
    isa-ok $_, FontFactory::DocFont::GChar;
}
is @gchars[0].Str, 'a';
is @gchars[1].Str, 'B';
is @gchars[2].Str, ' ';
is @gchars[3].Str, 'd';

#my $s = $df.String: "some text;
#isa-ok $s, FontFactory::String;

done-testing;
