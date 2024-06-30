use Test;

use QueryOS;

# we rely on the system locate comand,
# ensure it is available

my $os = OS.new;

my $debug = 0;

my ($n, $s, $exit, $proc, @lines);
my ($n2, $s2, @lines2);

is 1, 1; # for Mac and Windows

if $os.is-linux {

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

}


done-testing;
