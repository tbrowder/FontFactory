use Test;

# we rely on the system locate comand,
# ensure it is available

my $debug = 0;

my ($n, $s, $exit, $proc, @lines);
my ($n2, $s2, @lines2);

my $f1 = "harfbuzz";

# expect to find harfbuzz
$proc  = run "locate", "$f1", :out;
@lines = $proc.out.slurp(:close).lines;
$exit  = $proc.exitcode;
is $exit, 0, "locate harfbuzz works";
$n = @lines.elems;
cmp-ok $n, '>', 1, "multiple files found";
$s = @lines.head // "";
say "DEBUG s = '$s'" if $debug;

done-testing;
