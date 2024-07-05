use Test;

use QueryOS;

# we rely on the system find command

my $os = OS.new;

my $debug = 0;

my ($n, $s, $exit, $proc, @lines);
my ($n2, $s2, @lines2);

is 1, 1; # for Mac and Windows

my $cmd;
my $f1 = "libharfbuzz.a";
if $os.is-linux {
    #$cmd = "find /usr -type f -name \"{$f1}*\"";
    $cmd = "find /usr -type f -name";
    if $debug {
        say qq:to/HERE/;
        DEBUG: \$cmd:
        $cmd
        HERE
    }
    if $debug {
        say "DEBUG: \$cmd words:";
        say "|$_|" for $cmd.words;
    }

    # expect to find harfbuzz
    $proc  = run $cmd.words, $f1, :out;
    @lines = $proc.out.slurp(:close).lines;
    $exit  = $proc.exitcode;
    is $exit, 0, "find '$f1'";
    $n = @lines.elems;
    cmp-ok $n, '>', 0, "one or more  files found";
    $s = @lines.head // "";
    say "DEBUG s = '$s'" if $debug;
}

done-testing;
