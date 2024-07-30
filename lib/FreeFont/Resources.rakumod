unit module FreeFont::Resources;

#===== exported routines
sub get-meta-hash(:$debug --> Hash) is export {
   $?DISTRIBUTION.meta 
}

sub show-resources(:$debug --> List) is export {
    my %h = get-resources-hash;
    say "Resources (basenames => path):";
    for %h.keys.sort -> $k {
        my $d = %h{$k}.IO.parent;
        say "  $k => $d";
    }

    # say "  $_" for %h.keys.sort;
}

sub download-resources(:$debug --> List) is export {
    my %h = get-resources-hash;
    say "Downloading resources:";
    for %h.keys.sort -> $basename {
        my $path = %h{$basename};
        my $s = get-resource-content $path;
        spurt $basename, $s;
        say "  $basename";
    }
}

sub get-resources-hash(:$debug --> Hash) is export {
    my @list = get-resources-paths;
    # convert to a hash: key: file.basename => path
    my %h;
    for @list -> $path {
        my $f = $path.IO.basename;
        %h{$f} = $path;
        if $debug {
            note "DEBUG: basename: '$f' path: '$path'";
        }
    }
    %h
}

sub get-resource-content(
    $path,
    :$bin,
    :$debug,
) is export {
    my $p = $path;

    #my $exists = resource-exists $path;
    unless $p.IO.e and $p.IO.r {
        return 0; 
    }

    =begin comment
    $bin = False;
    if $p ~~ /:i otf|ttf / {
        $bin = True;
    }
    elsif $p !~~ Str {
        $bin = True;
    }
    =end comment

    my $s = $?DISTRIBUTION.content($path).open.slurp(:$bin, :close);
    $s
} # sub get-resource-content($path){

#===== non-exported routines
sub get-resources-paths(:$debug --> List) {
    my @list =
        $?DISTRIBUTION.meta<resources>.map({"resources/$_"});
    @list
}

=begin comment
sub resource-exists($path? --> Bool) {
    return False if not $path.defined;

    # "eats" both warnings and errors; fix coming to Zef
    # as of 2023-10-29
    # current working code courtesy of @ugexe
    try {
        so quietly $?DISTRIBUTION.content($path).open(:r).close; # may die
    } // False;
}
=end comment
