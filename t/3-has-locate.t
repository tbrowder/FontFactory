use Test;

use QueryOS;

# we rely on the system locate comand,
# ensure it is available

my $debug = 0;

my ($n, $s, $exit, $proc, @lines);
my ($n2, $s2, @lines2);

my $os = OS.new;
my $cmd;

if $os.is-linux {
    $cmd = "locate";
}
elsif $os.is-macos {
    $cmd = "mdfind -name";
}
elsif $os.is-windows {
    $cmd = "locate";
}

my $f1 = "FreeSerif.otf";
my $f2 = "XbrzaChiuS";

# expect at least one find and no error
$proc  = run $cmd, $f1, :out;
@lines = $proc.out.slurp(:close).lines;
$exit  = $proc.exitcode;
is $exit, 0, "$cmd '$f1' works";
$n = @lines.elems;
cmp-ok $n, '>', 0, "one or more files found";
$s = @lines.head // "";
say "DEBUG s = '$s'" if $debug;

# expect zero finds but no error
$proc  = run $cmd, $f2, :out, :err;
@lines  = $proc.out.slurp(:close).lines;
@lines2 = $proc.err.slurp(:close).lines;
$exit   = $proc.exitcode;

is $exit, 1, "file not found, exitcode 1";
$n  = @lines.elems;
$n2 = @lines2.elems;
cmp-ok $n, '==', 0, "empty out as expected";
$s  = @lines.head // "";
$s2 = @lines2.head // "";
say "DEBUG s  = '$s'" if $debug;
say "DEBUG s2 = '$s2'" if $debug;

done-testing;
