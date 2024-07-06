use Test;

use QueryOS;
use File::Temp;

use FreeFont::BuildUtils;

# access the /resources/* content
my $f1 = "resources/micrenc.ttf";
my $f2 = "resources/GnuMICR.otf";
my $f3 = "resources/DigitalGraphicLabs.html";
my $f4 = "resources/license.txt";

for $f1, $f2, $f3, $f4 -> $f {
#for $f1 -> $f {
    my $b = $f.IO.basename;
    my $s;
    my $bin = False;
    if $b ~~ /:i micr / {
        $bin = True;
    }

    lives-ok {
        $s = get-resource-content $f, :$bin;
    }, "get content of '$b'";
    
    with $bin {
        when $_.so { is $s.^name, 'Buf[uint8]' }
        when not $_.so { is $s.^name, 'Str' }
    }

}

done-testing;

=finish


my $debug = 1;

my ($n, $s, $exit, $proc, @lines);
my ($n2, $s2, @lines2);

my $os = OS.new;


my $cmd;

if $os.is-linux {
    $cmd = "find /usr/share/fonts -type f -name ";
}
elsif $os.is-macos {
    # basename?
    $cmd = "find -L /opt -type f -name ";
}
elsif $os.is-windows {
    $cmd = "find";
}

my $f1;
if $os.is-windows {
    $f1 = "DejaVuSerif.ttf";
}
else {
    $f1 = "FreeSerif.otf";
}
my $f2 = "XbrzaChiuS";

# expect at least one find and no error
$proc  = run $cmd.words, $f1, :out;
@lines = $proc.out.slurp(:close).lines;
$exit  = $proc.exitcode;
is $exit, 0, "$cmd '$f1' works";
$n = @lines.elems;
$s = @lines.head // "";
cmp-ok $n, '>', 0, "1st found: '$s'";
say "DEBUG first found = '$s'" if $debug;

# expect zero finds but no error
$proc  = run $cmd.words, $f2, :out, :err;
@lines  = $proc.out.slurp(:close).lines;
@lines2 = $proc.err.slurp(:close).lines;
$exit   = $proc.exitcode;

if $os.is-linux {
    is $exit, 0, 
        "file not found, exitcode $exit";
}
elsif $os.is-macos {
    is 1, 1, "mac exitcode for not found = '$exit'";
}

$n  = @lines.elems;
$n2 = @lines2.elems;
cmp-ok $n, '==', 0, "empty out as expected";
$s  = @lines.head // "";
$s2 = @lines2.head // "";
say "DEBUG s  = '$s'" if $debug;
say "DEBUG s2 = '$s2'" if $debug;

done-testing;
