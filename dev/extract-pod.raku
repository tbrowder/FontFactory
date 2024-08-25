#!/usr/bin/env raku

# SEE COKE's link for reading a pod file

use experimental :rakuast;
%*ENV<RAKUDO_RAKUAST> = 1;

my $pod-file = "../docs/README.rakudoc";
if not @*ARGS {
    print qq:to/HERE/;
    Usage: {$*PROGRAM} go | <rakudoc file>

    Extracts pod into a list of objects in a suitable format
    for processing into a PDF document.
    document.

    See details of RakuAST rakudoc parsing at:
        http://github.com/Rakudo/rakudo/lib/RakuDoc/To/Text.rakumod

    HERE
    exit;
}

my @unhandled-pod;
my @pod-chunks; # a global array to collect chunks from the pod walk

for $pod-file.IO.slurp.AST.rakudoc -> $pod-node {
    #say dd $pod-node;
    #exit;
    #  $=pod
    walk-pod $pod-node;
}

if @pod-chunks {
    say "Dumping pod chunks:";
    say "  $_" for @pod-chunks;
}

#=== subroutines ====
sub walk-pod($node, :$debug) is export {
    # as defined in the link above as "sub walk($node)"
    # also see the supporting test code using nqp and precomp and cache

    # push chunks to @pod-chunks for further processing

    my @children;

    =begin comment
    my $Typ = "(none)";
    my $Nam = "(none)";
    my $Nam = $node.^name // "(none)";
    my $Typ = $node.type  // "(none)";

    note qq:to/HERE/;
    DEBUG: found new node 
      pod type name: $Nam
          node.type: $Typ
    HERE
    =end comment

    my ($pod-type-name, $node-type) = "N/A", "N/A";
    with $node {
        when ~~ RakuAst::Doc::Paragraph {
            $node-type-name = "RakuAst::Doc::Paragraph";
        }
        when ~~ RakuAst::Doc::Block {
            $node-type-name = "RakuAst::Doc::Block";
        }
        default {
        }
    }

    if $node ~~ RakuAST::Doc::Paragraph {
        @children = $node.atoms;
    }
    elsif $node ~~ RakuAST::Doc::Block {
        # some other types to handle later:
        my $typ = $node.type;
        $Typ = $typ;
        if $node.type eq 'code'|'implicit-code'|'comment'|'table' {
            note "NOTE: skipping node typ '$typ' for now." if 1 or $debug;
            @unhandled-pod.push: $typ;
            return;
        }
        @children = $node.paragraphs;
    }
    elsif $node ~~ RakuAST::Doc::Markup {
        # handles formatting code like B<>, C<>, etc.
        # TODO fix this
        # some other types to handle later:
        my $typ = "Markup"; #$node.type;
        $Typ = $typ;
        $Nam = $node.^name;
        
        if 1 {
            note "NOTE: skipping node name '$Nam', type '$typ' for now."
               if 1 or $debug;
            @unhandled-pod.push: $typ;
            return;
        }
        @children = $node.atoms;

        #note "WARNING: Unhandled pod node type: $node.^name";
    }
    else {
        # report unhandled types
        note "WARNING: Unhandled pod node name: $node.^name";
    }

    my $nc = @children.elems;
    my $nam = $node.^name;
    my $typ = $Typ;
    note qq:to/HERE/;
    NOTE: found $nc child nodes for node name '$nam' and type '$typ'.
    HERE
    for @children -> $child {
        =begin comment
        if $child ~~ Str {
            @pod-chunks.push: $child;
            next;
        }
        =end comment
        walk-pod $child;
    }
} 
