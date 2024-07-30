unit module FreeFont::Utils;

use File::Temp;
use File::Find;
use QueryOS;
use YAMLish;

use FreeFont::X::FontHashes;
use FreeFont::Resources;

%number = %FreeFont::X::FontHashes::number;

# Primarily for Windows use to get GNU FreeFont
# files. Does the whole
# process from download to unpacking
# to installing in the desired
# directory. See /dev/get.raku.
# This should also work on other OSs
# if need be.
sub install-gnu-freefont(
    :$dir is copy,
    :$debug,
    ) is export {
    # Given a target directory, 
    # download and unpack the fonts
    # into the desired directory $dir 
    # (default is the user's
    # '$HOME/.FreeFont/fonts/'.
    unless $dir.defined {
        $dir = "{%*ENV<HOME>}/.FreeFont/fonts";
        mkdir $dir;
    }
    $dir = $*CWD if not $dir.defined;

    # We unpack in a temp dir
    my $tdir0 = tempdir;
    my $tdir  = "$tdir0/fonts";
    mkdir $tdir;

    # source links
    my $s1 = "https://ftp.gnu.org/gnu/freefont/freefont-otf-20120503.tar.gz";
    my $f1 = "freefont-otf-20120503.tar.gz";
    my $r2 = "https://ftp.gnu.org/gnu/freefont/freefont-otf-20120503.tar.gz.sig";
    my $f2 = "freefont-otf-20120503.tar.gz.sig";
    my @tpaths;
    #unless $f1.IO.e {
    my $log = "";
    unless @tpaths {
        chdir $tdir;
        run("wget", "-o $log", $s1);
        #my $cmd = "tar -xvzf $f1";
        my $cmd = "tar -xzf $f1";
        run $cmd.words;
    }
    # collect the files
    @tpaths = find :dir($tdir), :name(/'.otf'$/), :type<file>;
    # reality check
    if 0 and $debug {
        say "DEBUG tpaths:";
        for @tpaths -> $path {
            say "  $path";
        }
        say "DEBUG EXIT"; exit;
    }

    # create a hash
    my %tpaths;
    for @tpaths -> $p {
        my $b = $p.IO.basename;
        %tpaths{$b} = $p;
    }

    my $all = True;
    my @bnames;
    for 1...12 -> $n {
        my $bname = %number{$n}<basename>;
        if %tpaths{$bname}:exists {
            @bnames.push: $bname;
        }
        else {
            say "WARNING: file '$bname' not found.";
            $all = False;
        }
    }
    
    if not $all {
        die "FATAL: Unsuccessful access to '$f1'";
    }

    # install the 12 files
    for @bnames -> $bname {
        next if "$dir/$bname".IO.e;
        copy $bname, $dir;
    }
}

sub help is export {
    print qq:to/HERE/;
    Usage: {$*PROGRAM.basename} <mode>

    Modes:
      a - all
      p - print PDF of font samples
      d - download example programs
      L - download licenses
      s - show /resources contents
    HERE
    exit
}

sub with-args(@args) is export {
    for @args {
        when /:i a / {
            exec-d;
            exec-p;
            exec-L;
            exec-s;
        }
        when /:i d / {
            exec-d
        }
        when /:i p / {
            exec-p
        }
        when /:i L / {
            exec-L
        }
        when /:i s / {
            exec-s
        }
        default {
            say "ERROR: Unknown arg '$_'";
        }
    }
}

# local subs, non-exported
sub exec-d() {
    say "Downloading example programs...";
}
sub exec-p() {
    say "Downloading a PDF with font samples...";
}
sub exec-L() {
    say "Downloading font licenses...";
}
sub exec-s() {
    say "List of /resources:";
    my %h = get-resources-hash;

    =begin comment
    my %m = get-meta-hash;
    # NOTE: get-meta-hash doesn't work unless the module is installed!!!
    =end comment

    my %m = load-yaml "META6.json".IO.slurp;
    my @arr = @(%m<resources>);
    for @arr.sort -> $k {
        say "  $k";
    }
}
