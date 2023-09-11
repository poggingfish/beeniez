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
    my %functions;
    method _arg ($/) {
        if !($/<arg><expr> ~~ Nil) {
            self.construct($/<arg><expr>, False);
        } elsif !($/<arg><ident> ~~ Nil) {
            $out.print("\$$($/<arg>)")
        }
        else {
            $out.print($/<arg>)
        }
    }
    method print ($/, Bool $semi = True) {
        $out.print("say(");
        self._arg($/<args>[0][0]);
        $out.print(ss(")",$semi));
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
    method func($/, Bool $semi = True) {
        # Things are getting funcy now.
        # - Adam Stanley, 1996 (codegen.c)

        my $argc = 0;

        $out.print("sub $($<args>[0][0]<arg>)\(");
        for $<args>[0][1..*] -> $x {
            if !( $x<arg><ident> ~~ Nil ) {
                $out.print("\$$($x<arg><ident>),");
                $argc++;
            } else {
                $out.print(")\{return ");
                self._arg($x);
                $out.print("\}\n");
            }
        }
        my $fun_name = "$($<args>[0][0]<arg>)";
        %functions{$fun_name} = $argc;
    }
    method call($/, Bool $semi = True) {
        $out.print("$($<func>)\(");
        for $<args>[0] -> $arg {
            self._arg($arg);
            $out.print(",");
        }
        $out.print(ss(")",$semi));
    }
    method var($/, Bool $semi = True) {
        $out.print("my \$$($<args>[0][0]<arg><ident>):=");
        self._arg($<args>[0][1]);
        $out.print(ss("",$semi));
    }
    method construct ($/, Bool $semi = True) {
        for $/<expr> -> $top {
            if $top<func> eq "p" {
                self.print($top, $semi);
            }
            elsif $top<func> eq "a" {
                self.add($top, $semi);
            }
            elsif $top<func> eq "s" {
                self.sub($top, $semi);
            }
            elsif $top<func> eq "f" {
                self.func($top, $semi);
            } elsif $top<func> eq "v" {
                self.var($top, $semi);
            }
            elsif %functions{$top<func>}:exists {
                if %functions{$top<func>} ne $top<args>[0].elems {
                    say "Incorrect argument count when calling $($top<func>)";
                    exit 1;
                }
                self.call($top, $semi);
            } else {
                say "Unexpected token $top<func>";
                exit 1;
            }
        }
    }
    method TOP ($/) {
        $out = open "out.nqp", :w;
        self.construct(make $/);
        $out.close();
    }
}