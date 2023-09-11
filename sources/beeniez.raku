#!/usr/bin/env raku

# String parser stolen from https://modules.raku.org/dist/JSON::Tiny:cpan:MORITZ/lib/JSON/Tiny/Grammar.pm
use lib "sources/lib";
use generator;
grammar language {
    token TOP { [<expr=.topexpr><semi>\n? | \n]* }
    token args { [(<arg>\,?<weeniespace>?)+] }
    token arg { <num> | <string> | <expr> | <ident> }
    token topexpr { <func=.ident><weeniespace>?<args=.args> }
    token expr { \([<expr=.topexpr>]*\) }
    token weeniespace { \t|<space> }
    token ident { <alpha>+ }
    token semi { \; }
    token num { \-?\d+ }
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


sub MAIN($file, $dump = False) {
    my $fh = open $file, :r;
    if !$dump {
        language.parse($fh.slurp, :actions(Language)).made;
    } else {
        say language.parse($fh.slurp);
    }
    run "nqp", "out.nqp";
}