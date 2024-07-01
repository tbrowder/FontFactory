unit module FreeFont::Utils;

use QueryOS;

sub locate-font(
    $font, 
    :$debug,
    ) is export {
    # this sub is called by 
    # sub find-freefont in module 
    # FreeFont::BuildUtils
    # but only if it's not already
    # in $HOME/.FreeFont/config.yml

    # we rely on the system locate 
    # comand,

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
    $n = @lines.elems;
    $s = @lines.head // "";
    say "DEBUG s = '$s'" if $debug;

    # expect zero finds but no error
    $proc  = run $cmd, $f2, :out, :err;
    @lines  = $proc.out.slurp(:close).lines;
    @lines2 = $proc.err.slurp(:close).lines;
    $exit   = $proc.exitcode;

    $n  = @lines.elems;
    $n2 = @lines2.elems;
    $s  = @lines.head // "";
    $s2 = @lines2.head // "";
    say "DEBUG s  = '$s'" if $debug;
    say "DEBUG s2 = '$s2'" if $debug;

}

