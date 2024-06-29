use Test;
# we rely on the system locate comand,
# ensure it is available

my $debug = 0;
my ($n, $s, $exit, $proc, @lines);

my $f1 = "locate";
my $f2 = "XbrzaChiuS";

# expect at least one find and no error
$proc  = run "locate", "$f1", :out;
@lines = $proc.out.slurp(:close).lines;
$exit  = $proc.exitcode;

is $exit, 0, "locate locate works";
$n = @lines.elems;
cmp-ok $n, '>', 1, "multiple files found";
$s = @lines.head // "";
say "DEBUG s = '$s'" if $debug;

# expect zero finds but no error
$proc = run "locate", "$f2", :out;
@lines = $proc.out.slurp(:close).lines;
$exit  = $proc.exitcode;

is $exit, 1, "file not found, exitcode 1";
$n = @lines.elems;
cmp-ok $n, '==', 0, "empty out as expected";
$s = @lines.head // "";
say "DEBUG s = '$s'" if $debug;

done-testing;
