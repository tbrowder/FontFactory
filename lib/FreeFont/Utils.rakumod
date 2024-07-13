unit module FreeFont::Utils;

use File::Temp;
use File::Find;
use QueryOS;
use YAMLish;
use FreeFont::X::FontHashes;

%number = %FreeFont::X::FontHashes::number;

# Primarily for Windows use to get GNU FreeFont
# files. Eventually do the whole
# process from download to unpacking
# to installing in the desired
# directory. See /dev/wget.raku.
# This should also work on other OSs
# if need be.
sub install-gnu-freefont(
    :$dir is copy,
    #$https, 
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
    my $tdir = 0;
    my $f1 = "https://ftp.gnu.org/gnu/freefont/freefont-otf-20120503.tar.gz";
    my $f2 = "https://ftp.gnu.org/gnu/freefont/freefont-otf-20120503.tar.gz.sig";
    chdir $tdir;
    run "wget", $f1;
    #run "wget", $f2;
    unless $f1.IO.e {
        run("wget", $f1);
        my $cmd = "tar -xvzf $f1";
        run $cmd.words
    }
    # reality check
    my $all = True;
    my @bnames;
    for 1...12 -> $n {
        my $bname = %number{$n}<basename>;
        if not $bname.IO.r {
            say "WARNING: file '$bname' not found.";
            $all = False;
        }
        else {
            @bnames.push: $bname;
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


