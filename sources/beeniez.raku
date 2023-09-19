#!/usr/bin/env raku
# String parser stolen from https://modules.raku.org/dist/JSON::Tiny:cpan:MORITZ/lib/JSON/Tiny/Grammar.pm
if %*ENV{"__BEENIEZ_PATH"}:exists and !(%*ENV{"__BEENIEZ_PATH"} ~~ Any) {
    use lib "/"~%*ENV\{'__BEENIEZ_PATH'}.gist~"/sources/lib";
} else {
    use lib "sources/lib";
}
use generator;
use grammar;
use Terminal::ANSIColor;

sub MAIN($file,
    Bool :$dump, #= Dump the AST of the program to stdout
    Str  :$outfile = "out.nqp", #= The output file for NQP.
    Bool :$run, #= Run the program after compilation.
    Bool :$delete #= Delete the output file after compilation.
    ) {
    my $fh = open $file, :r;
    if !$fh {
        say color('bold'), color('red'), "FATAL: Failed to open $file", color('reset');
        exit 1;
    }
    my $g = language.new(:quiet, :colors, :lastrule);
    my $compile = Language.new(outfile => $outfile);
    if !$dump {
        my $parsed = $g.parse($fh.slurp, :actions($compile));
        if $g.error {
            say .report with $g.error;
            exit 1;
        }
        $parsed.made;
    } else {
        say $g.parse($fh.slurp);
    }
    if $run {
        run "nqp", "--module-path=%*ENV{"__BEENIEZ_PATH"}/lib", $outfile;
    }
    if $delete {
        run "rm", $outfile;
    }
}