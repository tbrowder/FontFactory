use Test;

use File::Temp;
use File::Find;

use FreeFont::Resources;
use FreeFont::Font::Utils;

my @fils = find :dir("resources"), :type<file>;

my %bad;
my %good;
for @fils.kv -> $i, $path {
    my ($content, $copy, @res, $err, $basename, $debug);
    my ($bin, $utf8c8) = True, False;
    $debug = 0;

    $basename = $path.IO.basename;
    say "Processing file '$basename' at index $i";
    next if %good{$i}:exists;

    =begin comment
    given $path {
        when /:i '.' pdf $/ {
            $bin = True;
        }
        when /:i '.' raku $/ {
            $bin = True;
        }
    }
    =end comment


    $content = slurp-file $path, :$bin, :$utf8c8, :$debug;
    $copy = spurt-file $content, :$basename, :$bin, :$utf8c8, :$debug;
    @res = bin-cmp $path, $copy, :l(True), :$debug;
    $err = @res.shift;
    
    if $err == 0 {
        say "DEBUG: file $path roundtrips ok" if $debug;
        %good{$i} = $path;
    }
    else {
        say "File '$path' does not roundtrip";
        say "  $%_" for @res;
        %bad{$i} = $path;
    }
    #last if $i == 0;
}

done-testing;

=finish
my $orig-text = "some text";
my $tfil = "text.txt";

my $tmpdir = tempdir;

spurt-file  $orig-text, :basename($tfil), :dir($tmpdir);
my $copy-text = slurp-file "$tmpdir/$tfil";
is $copy-text, $orig-text;

done-testing;
