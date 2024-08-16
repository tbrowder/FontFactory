unit module FontFactory::OtherClasses;

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
