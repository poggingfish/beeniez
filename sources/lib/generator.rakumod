unit module generator;
=begin overview
Beeniez codegen.
=end overview


sub ss($str,$semi) {
    my $newstr = "$str";
    if $semi {
        $newstr = "$newstr;"
    }
    return $newstr;
}
class Language is export(:MANDATORY) {
    my $out;
    method _arg ($/) {
        if !($/<arg><expr> ~~ Nil) {
            self.construct($/<arg><expr>, False);
        } else {
            $out.print($/<arg>)
        }
    }
    method print ($/, Bool $semi = True) {
        if !($/<args>[0][0]<arg><expr> ~~ Nil) {
            $out.print("say(");
            self.construct($/<args>[0][0]<arg><expr>, False);
            $out.print(ss(")",$semi));
        } else {
            $out.print(ss("say($($/<args>[0]))",$semi));
        }
    }
    method add ($/, Bool $semi = True) {
        $out.print("(");
        self._arg($/<args>[0][0]);
        $out.print("+");
        self._arg($/<args>[0][1]);
        $out.print(")");
    }
    method sub ($/, Bool $semi = True) {
        $out.print("(");
        self._arg($/<args>[0][0]);
        $out.print("-");
        self._arg($/<args>[0][1]);
        $out.print(")");
    }
    method construct ($/, Bool $semi = True) {
        for $/<expr> -> $top {
            if $top<func> eq "p" {
                self.print($top, $semi);
            }
            if $top<func> eq "a" {
                self.add($top, $semi);
            }
            if $top<func> eq "s" {
                self.sub($top, $semi);
            }
        }
    }
    method TOP ($/) {
        $out = open "out.nqp", :w;
        self.construct(make $/);
        $out.close();
    }
}