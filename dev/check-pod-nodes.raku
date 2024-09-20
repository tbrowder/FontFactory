#!/usr/bin/env raku

use File::Find;

use experimental :rakuast;

BEGIN {
unless %*ENV<RAKULIB> eq "./lib" {
    note "FATAL: env var RAKULIB not set correctly...exiting";
    exit;
}
}

=begin overview

Validate, in a single pass, several characteristics of our
Rakudoc sources using RakuAST.

=head1 C<C>

Verify any C<C<>> tags have no internal trailing whitespace.
To explicitly allow it, prepend the C<C<>> with a
C<Z<ignore-code-ws>> comment, needed in rare cases.

=head1 Links

All URLS should appear inside C<L<>> tags, not in raw text.

=head1 brackets

Authors may forget to add a formatting code when
wrapping something in angle brackets:

    This was supposed to be <bold>.

This is valid pod, but in practice, these dangling <>'s often indicate an error.
Complain whenever we find them, except for infix:<> and prefix:<>

=end overview

my $dir = "../docs"; #.IO;
my @files = find :$dir, :type<file>;
#say " $_" for @files;
#exit;

my $*TRAILING-C-WHITESPACE-OK = False;
my $*INSIDE-LINK = False;
sub walk($node, 
         #:$parent = 0, # parent ID
         :$debug,
    ) {
    if $debug == 1 {
        my $nam = $node.^name;
        say "DEBUG: .^name: $nam";
    }
    elsif $debug == 2 {
        my $s = $node.gist;
        say "DEBUG: gist";
        say $s;
    }

    my @children;
    my $check-empty-tags = True;

    if $node ~~ RakuAST::Doc::Paragraph {
        @children = $node.atoms;
    } elsif $node ~~ RakuAST::Doc::Block {
        return if $node.type eq 'code'|'implicit-code'|'comment'|'table';
        @children = $node.paragraphs;
    } elsif $node ~~ RakuAST::Doc::Markup {
        $check-empty-tags = False;

        if $node.letter eq 'L' {
            $*INSIDE-LINK = True;
        }
        if $node.letter eq 'Z' and $node.atoms[0] eq 'ignore-code-ws' {
            $*TRAILING-C-WHITESPACE-OK = True;
        }
        elsif $node.letter eq 'C' {
            my $content = ~$node.atoms;
            if $*TRAILING-C-WHITESPACE-OK {
                #pass "Allowed trailing space on $node";
                note "WARNING: Allowed trailing space on $node";
            } else {
                #ok $content eq $content.trim-trailing, $node;
            }
            $*TRAILING-C-WHITESPACE-OK = False;
        } else {
            @children = $node.atoms;
        }
    } else {
        # If this hits, need to adapt test
        #flunk "new node type: $node.^name";
        say "WARNING: new node type: $node.^name";
    }

    for @children -> $child {
        if $child ~~ Str {
            if ! $*INSIDE-LINK {
                if $child ~~ / $<url>=[ 'http' 's'? '://' <-[/]>* '/'? ] / {
                    #flunk "URL found: $<url>";
                    say "URL found: $<url>";
                }
            }
            if $check-empty-tags && $child ~~ / $<bracketed>=['<' .*? '>'] / {
                next if $child.contains("prefix:<" | "infix:<" );
                #flunk ~$/<bracketed> ~ " is likely missing a formatting code";
                say "WARNING: " ~  ~$/<bracketed> ~ " is likely missing a formatting code";
            }
        } else {
            walk($child, :$debug);
        }
    }
    $*INSIDE-LINK = False;
}

use NewPod-Helper;

for @files -> $file {
    # handling just one file for now
    %*ENV<RAKUDO_RAKUAST>=1;
    for $file.IO.slurp.AST.rakudoc -> $pod {
        my $ID  = 0;
        my $gen = 0;
        my $pid = ++$ID;
        my $np  = NewPod.new: :$gen, :$pid, :$pod;
        #walk($pod, :$np, :$debug);
        #my $debug = 1;
        my $debug = 2;
        walk($pod, :$debug);
    }
    last;
}
