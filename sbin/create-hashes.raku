#!/usr/bin/env raku

# creates file FreeFont::BuildUtils

=begin comment
all font files in dir /usr/share/fonts/opentype/freefont
FreeSerif.otf
FreeSerifBold.otf
FreeSerifItalic.otf
FreeSerifBoldItalic.otf
FreeSans.otf
FreeSansBold.otf
FreeSansOblique.otf
FreeSansBoldOblique.otf
FreeMono.otf
FreeMonoBold.otf
FreeMonoOblique.otf
FreeMonoBoldOblique.otf
micrenc.ttf
=end comment

constant @fontnames =
# full name, code, code2, number
#   number is in order listed in
#   the Red Book, Appendix E.1
# Times equivalent (1-4)
"Free Serif se t 1",
"Free Serif Italic sei ti 2",
"Free Serif Bold seb tb 3",
"Free Serif Bold Italic sebi tbi 4",
# Helvetica equivalent (5-8)
"Free Sans sa h 5",
"Free Sans Oblique sao ho 6",
"Free Sans Bold sab hb 7",
"Free Sans Bold Oblique sabo hbo 8",
# Courier equivalent (9-12)
"Free Mono m c 9",
"Free Mono Oblique mo co 10",
"Free Mono Bold mb cb 11",
"Free Mono Bold Oblique mbo cbo 12",
"MICRE mi mi 13", # not listed in the Ted Book
;

my $debug = 0;
# the 4 hashes
my (%code, %code2, %shortname, %number);
# track the max size of each set of keys
my ($num-s, $cod-s, $cod2-s, $sho-s) = 0, 0, 0, 0;
my $siz;
# $num-s $cod-s $cod2-s $sho-s
for @fontnames.kv -> $i, $v is copy {
    my $n = $i + 1;
    # the last three words are 'code'
    #   'code2', and 'number', 
    #   respectively
    my @w = $v.words;
    say @w.raku if $debug;
    # error check
    my $N = @w.pop;
    $siz = $N.chars;
    $num-s = $siz if $siz > $num-s;
# $num-s $cod-s $cod2-s $sho-s

    if $N != $n {
        die "FATAL: n != N";
    }
    my $code2 = @w.pop;
    $siz = $code2.chars;
    $cod2-s = $siz if $siz > $cod2-s;
# $num-s $cod-s $cod2-s $sho-s

    say "code2 = '$code2'" if $debug;
    my $code  = @w.pop;
    $siz = $code.chars;
    $cod-s = $siz if $siz > $cod-s;
# $num-s $cod-s $cod2-s $sho-s

    say "code = '$code'" if $debug;
    # reassemble
    say @w.raku if $debug;
    $v = @w.join(" ");
    my $fullname  = $v;   # complete name, with spaces
    my $name       = $v;  # complete name, without spaces
    # delete spaces
    $name ~~ s:g/\s+//;

    my $shortname = $name;
    # all lower-case
    $shortname .= lc;
    $siz = $shortname.chars;
    $sho-s = $siz if $siz > $sho-s;
# $num-s $cod-s $cod2-s $sho-s

    # insert into the hashes
    %code{$code}           = $n;
    %code2{$code2}         = $n;
    %shortname{$shortname} = $n;
    # 7 values
    %number{$n}<code>      = $code;
    %number{$n}<code2>     = $code2;
    %number{$n}<shortname> = $shortname;
    %number{$n}<name>      = $name;
    %number{$n}<fullname>  = $fullname;
    %number{$n}<path>      = 0;
    %number{$n}<fontobj>   = 0;
}

for %number.keys.sort({$^a <=> $^b}) {
    say "Font number $_" if $debug;
    my $n = $_;
    my $code      = %number{$n}<code>;
    my $code2     = %number{$n}<code2>;
    my $shortname = %number{$n}<shortname>;
    my $name      = %number{$n}<name>;
    my $fullname  = %number{$n}<fullname>;
    my $path      = %number{$n}<path>;
    my $fontobj   = %number{$n}<fontobj>;
    if $debug {
        say "  code      = ", %number{$n}<code>;
        say "  code2     = ", %number{$n}<code2>;
        say "  shortname = ", %number{$n}<shortname>;
        say "  name      = ", %number{$n}<name>;
        say "  fullname  = ", %number{$n}<fullname>;
        say "  path      = ", %number{$n}<path>;
        say "  fontobj   = ", %number{$n}<fontobj>;
    }
}

# the hashes are assembled, write all
# to the new module 

my $f = "$*CWD/lib/FreeFont/BuildUtils.rakumod";
my $fh = open $f, :w;
$fh.print: q:to/HERE/;
# AUTO-GENERATED DO NOT EDIT
# CREATED BY /sbin/install

unit module FreeFont::BuildUtils;

constant %code is export = %(
HERE
for %code.sort(*.keys) {
    my ($k, $v) = .key, .value;
# $num-s $cod-s $cod2-s $sho-s
    $n = $cod-s;
    my $ks = sprintf = '%-*.*s', $n, $n, $k;
    $fh.say: "    $ks => $v,"
}

$fh.print: q:to/HERE/;
    # close the preceding hash
)

constant %code2 is export = %(
HERE
for %code2.sort(*.keys) {
    my ($k, $v) = .key, .value;
# $num-s $cod-s $cod2-s $sho-s
    $fh.say: "    $k => $v,"
}

$fh.print: q:to/HERE/;
    # close the preceding hash
);

constant %shortname is export = %(
HERE
for %shortname.sort(*.keys) {
    my ($k, $v) = .key, .value;
# $num-s $cod-s $cod2-s $sho-s
    $fh.say: "    $k => $v,"
}

$fh.print: q:to/HERE/;
    # close the preceding hash
);

constant %number is export = %(
HERE
for %number.keys.sort({$^a <=> $^b}) -> $k {
# $num-s $cod-s $cod2-s $sho-s
    $fh.say: "    $k => \{";
    my %h = %(%number{$k});
    for %h.sort(*.keys) {
        my ($key, $val) = .key, .value;
        # most values are strings, but
        # fontobj
        if $val ~~ Numeric {
            $fh.say: "        $key => $val"
        }
        else {
            $fh.say: "        $key => '$val'"
        }
    }
    $fh.say: "    },";
}

$fh.print: q:to/HERE/;
    # close the preceding hash
);
HERE

$fh.close;
