#!/usr/bin/env raku

# String parser stolen from https://modules.raku.org/dist/JSON::Tiny:cpan:MORITZ/lib/JSON/Tiny/Grammar.pm
if %*ENV{"__BEENIEZ_PATH"}:exists and !(%*ENV{"__BEENIEZ_PATH"} ~~ Any) {
    use lib %*ENV\{'__BEENIEZ_PATH'}.^name~"sources/lib";
} else {
    use lib "sources/lib";
}
use generator;
use Grammar::PrettyErrors;

grammar language does Grammar::PrettyErrors  {
    rule TOP { [<expr=.topexpr><semi>\n? % ' ' || \n]+ }
    rule args { [(<arg>\,?<weeniespace>?)*] }
    rule arg { <num> || <string> || <expr> || <ident> || <bool_op> || \∅ }
    rule topexpr { <func=.ident><weeniespace>?<args=.args> }
    rule expr { \([([\^|\∘]<arg=.arg>) || <expr=.topexpr>*]\) }
    token weeniespace { \t || <space> }
    token ident { <identifier>+ }
    rule bool_op { [<eq=.eq> || <ne=.ne>] }
    token eq { \=\= }
    token ne { \!\= }
    token semi { \; }
    token num { \-?\d+ }
    token identifier { <alpha>|<unicodes> }
    token unicodes { <[ \x[007F] .. \x[FFFF] ]> }
    token string {
        :ignoremark
        ('"') ~ \" [ <str> | \\ <str=.str_escape> ]*
    }
    token str {
        <-["\\\t\x[0A]]>+
    }
    token str_escape {
        <["\\/bfnrt]> | 'u' <utf16_codepoint>+ % '\u'
    }
    token utf16_codepoint {
        <.xdigit>**4
    }
}


sub MAIN($file,
    Bool :$dump, #= Dump the AST of the program to stdout
    Str  :$outfile = "out.nqp", #= The output file for NQP.
    Bool :$run, #= Run the program after compilation.
    Bool :$delete #= Delete the output file after compilation.
    ) {
    my $fh = open $file, :r;
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
        run "nqp", $outfile;
    }
    if $delete {
        run "rm", $outfile;
    }
}