unit module FontFactory::OtherClasses;

use Text::Utils :strip-comment;
use Font::FreeType;
use PDF::Font::Loader :load-font;
use PDF::Content::FontObj;

use FontFactory::Config;

=begin pod

=head1 Class String

Class B<String> provides all the scaled size
metrics for a string set with a given font
at a given size:

=begin code
class String is export {
=end code

=end pod

class String is export {
    #== required
    has $.text           is required;
    has $.font           is required;
    has $.size           is required;
    #== defaults
    has $.kern           = True;
    has $.ligatures      = True;
    has $.underline      = False;
    has $.strike-through = False;
    has $.overline       = False;
    #== calculated
    has $.stringwidth    is rw;
    has $.top-bearing    is rw;
    has $.left-bearing   is rw;
    has $.bottom-bearing is rw;
    has $.right-bearing  is rw;
    has $.right-advance  is rw;
    has @.bbox           is rw;
  
    method check {
        my $err = 0;
        ++$err if not defined $!stringwidth;
    }
}

class Config is export {
    # holds the data read from the EXISTING Config file
    # which should have valid paths (checked and set by FF on startup)
    has $.number;
    #...
    submethod TWEAK {
        # the 4 hashes
        my (%code, %code2, %shortname, %number);
        my $N = 0;
        for "$*HOME/.FontFactory/Config".IO.lines.kv -> $i, $line is copy {
            $line = strip-comment $line;
            next if $line !~~ /\S/;
            # a data line
            $N += 1;
            my @w = $line.words;
            # 2 to 6 fields
            my $nw = @w.elems;
            die "FATAL: Config has $nw fields, should be 3 to 6" if not 2 < $nw < 7;
            my $n = @w.shift; # field 1
            die "FATAL: Config data line $N has diff number: $n vs $N" 
                if not $n == $N;
            $!number = $n; 
            $!path   = @w.pop; # last field (default: 6)
            $!name   = @w.shift; # field 2

            my $is-default if $nw < 16;
            if $is-default {
                # now 3 elements, take from the end element
                $!alias = @w.pop; # field 5
                $!code2 = @w.pop; # field 4
                $!code  = @w.pop; # field 3

                next;
            }
            # non-fault user entries, 3 to 5, pick from first element
            $!code  = @w.elems ?? @w.shift !! "";
            $!code2 = @w.elems ?? @w.shift !! "";
            $!alias = @w.elems ?? @w.shift !! "";
        }
    }
   
}

