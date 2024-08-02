#!/bin/env raku

use File::Temp;
use File::Find;

use lib "../lib";
use FreeFont::Font::Utils;

my $debug = 0;

=begin comment
my $path = "fonts/FreeSerif.otf";
my $s = $path.IO.slurp(:enc<utf8-c8>);
my $o = "dup.otf";
spurt $o, $s, :enc<utf8-c8>;
say "See dup file '$o'";
=end comment

my $bdir = $debug ?? "/tmp" !! tempdir;
my $tdir = "$bdir/spurt";
mkdir $tdir;

my @dirs;

# make a hash of font files
@dirs = <
/usr/share/fonts/opentype
/usr/share/fonts/truetype
/usr/share/fonts/type1
>;
# make a hash of PDF files
@dirs = <
/home/tbrowde
>;

my %h;
for @dirs -> $dir {
    my @f = find :$dir, :type<file>;
    for @f -> $path {
        my $b = $path.IO.basename;
        next if not $b ~~ /:i '.' pdf $/;
        if %h{$b}:exists {
            next;
        }
        else {
            %h{$b} = $path;
        }
    }
}
my $nf = %h.elems;
#say "Found $nf unique font files.";
say "Found $nf unique PDF files.";
#exit;

my @fils = %h.values;

my $bad = 0;
for @fils -> $path {
    # slurp and spurt and compare with Gnu 'cmp'
    my $basename = $path.IO.basename;

    my $s;

    #$s = $path.IO.slurp(:enc<utf8-c8>);
    $s = $path.IO.slurp(:bin);

    my $o = IO::Path.new: :$basename, :dir($tdir);
    my $ofil = "$tdir/$o";

    if 0 or $debug {
        say "DEBUG file to be spurted is '$ofil'";
        next;
    }

    #$ofil.IO.spurt: $s, :enc<utf8-c8>;
    $ofil.IO.spurt: $s, :bin;

    #last if 1;

    my @res = bin-cmp :orig($path), :copy($ofil); #, :debug(1);
    if 0 {
        say "DEBUG: \@res = {@res.gist}"; 
    }
    my $exit = @res.shift;

    unless $exit == 0 {
        say "Files '$ofil' (copy) and '$path' (orig) are different.";
        ++$bad;
        my $s1 = $ofil.IO.s; # ~ :s; # .size;
        my $s2 = $path.IO.s; # ~ :s; # .size;
        say "  Sizes: '$s1' and '$s2'.";
    }
    #last if 1;
}

say "Found $bad bad files out of $nf";

=finish

sub bin-cmp($f1, $f2, :$debug --> Bool) is export {
    # Runs Gnu 'cmp' and compares the two inputs byte by byte
    # Returns True if same, False otherwise.
    # exit codes: 0 - same, 1 - diff, 2 - trouble

#    my $cmd = "cmp -s $f1 $f2"; # silent
    my $cmd = "cmp -l $f1 $f2"; # list bytes differing and their values
#    my $cmd = "cmp -b -n16 $f1 $f2"; # list n bytes differing
#    my $cmd = "cmp -b $f2"; # list n bytes differing

    #my $proc = run("cmp -s $f1 $f2".words, :out, :err);
    #my $proc = run("cmp -l $f1 $f2".words, :out, :err);
    my $proc = run($cmd.words, :out, :err);
    my $err = $proc.exitcode; 

    my @lines  = $proc.out.slurp(:close).lines;
    my @lines2 = $proc.err.slurp(:close).lines;
    if $debug {
        if $err == 0 {
            say "DEBUG: no diffs found";
        }
        else {
        say "  DEBUG: byte differences:";
        for @lines {
            say "    $_";
        }
        for @lines2 {
            say "    $_";
        }
        }
    }
    $err == 0 ?? True !! False
}

BEGIN {
@fils = <
../resources/fonts/CMC7.ttf
../resources/fonts/GnuMICR.otf
../resources/fonts/micrenc.ttf
../resources/bin/ff-font-samples.pdf
../resources/bin/example.raku
../resources/bin/print-sample.raku
../resources/bin/strikethrough.info
../resources/docs/CMC7.txt
../resources/docs/micrenc-license.txt
../resources/docs/DigitalGraphicLabs.html
../resources/docs/COPYING.txt
../resources/docs/GPL-VERSION3.txt
>;
}

=finish

sub MAIN(Str $filename) {
    my $face = Font::FreeType.new.face($filename);

    say "Family name: ", $face.family-name;
    say "Style name: ", $_
        with $face.style-name;
    say "PostScript name: ", $_
        with $face.postscript-name;
    say "Format: ", $_
        with $face.font-format;

    my @properties;

    @properties.push: 'Bold' if $face.is-bold;
    @properties.push: 'Italic' if $face.is-italic;
    say @properties.join: '  ' if @properties;

    @properties = ();
    @properties.push: 'Scalable'    if $face.is-scalable;
    @properties.push: 'Fixed width' if $face.is-fixed-width;
    @properties.push: 'Kerning'     if $face.has-kerning;
    @properties.push: 'Glyph names' ~
                      ($face.has-reliable-glyph-names ?? '' !! ' (unreliable)')
      if $face.has-glyph-names;
    @properties.push: 'SFNT'        if $face.is-sfnt;
    @properties.push: 'Horizontal'  if $face.has-horizontal-metrics;
    @properties.push: 'Vertical'    if $face.has-vertical-metrics;
    with $face.charmap {
        @properties.push: 'enc:' ~ .key.subst(/^FT_ENCODING_/, '').lc
            with .encoding;
    }
    say @properties.join: '  ' if @properties;

    say "Units per em: ", $face.units-per-EM if $face.units-per-EM;
    if $face.is-scalable {
        with $face.bounding-box -> $bb {
            say sprintf('Global BBox: (%d,%d):(%d,%d)',
                        <x-min y-min x-max y-max>.map({ $bb."$_"() }) );
        }
        say "Ascent: ", $face.ascender;
        say "Descent: ", $face.descender;
        say "Text height: ", $face.height;
    }
    say "Number of glyphs: ", $face.num-glyphs;
    say "Number of faces: ", $face.num-faces
      if $face.num-faces > 1;

    if $face.fixed-sizes {
        say "Fixed sizes:";
        for $face.fixed-sizes -> $size {
            say "    ",
            <size width height x-res y-res>\
                .grep({ $size."$_"(:dpi)})\
                .map({ sprintf "$_ %g", $size."$_"(:dpi) })\
                .join: ", ";
        }
    }
}
