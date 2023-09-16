
unit module grammar;
=begin overview
Beeniez codegen.
=end overview

use Grammar::PrettyErrors;

grammar language does Grammar::PrettyErrors is export(:MANDATORY) {
    rule TOP { [<expr=.topexpr><semi>\n? % ' ' || \n]+ }
    rule args { [(<arg>\,?<weeniespace>?)*] }
    rule arg { <num> || <string> || <expr> || <ident> || <bool_op> || \∅ || <array> || <cexpr> }
    rule array { \[<args>\] }
    rule topexpr { <func=.ident><weeniespace>?<args=.args> }
    rule expr { \([([\^|\∘]<arg=.arg>) || <expr=.topexpr>*]\) }
    rule cexpr { \{\n?<weeniespace>+?<TOP>\} }
    token weeniespace { \t || <space> }
    token ident { <identifier>+ }
    rule bool_op { [\=\= | \!\= | \< | \> | \>\= | \<\=] }
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