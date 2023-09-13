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
    has Str $.outfile = "out.nqp";
    method _arg ($/) {
        if !($/<arg><expr> ~~ Nil) {
            if !($/<arg><expr>[0]<arg> ~~ Nil) {
                self._arg($/<arg><expr>[0]);
            } else {
                self.construct($/<arg><expr>, False);
            }
        } elsif !($/<arg><ident> ~~ Nil) {
            $out.print("\$$($/<arg>)")
        } else {
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
        my $fun_name = "";
        if !( $<args>[0][0]<arg><string> ~~ Nil ) {
            $out.print("sub $($<args>[0][0]<arg><string><str>)\(");
            $fun_name = "$($<args>[0][0]<arg><string><str>)";
        } elsif !( $<args>[0][0]<arg><ident> ~~ Nil ) {
            $out.print("sub $($<args>[0][0]<arg><ident>)\(");
            $fun_name = "$($<args>[0][0]<arg><ident>)";
        } else {
            say "Functions expect either an IDENT or STRING as their name.";
            exit 1;
        }
        for $<args>[0][1..*] -> $x {
            if !( $x<arg><ident> ~~ Nil ) {
                self._arg($x);
                $argc++;
            } else {
                $out.print(")\{return ");
                self._arg($x);
                $out.print("\}\n");
            }
        }
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
        $out.print("my ");
        self._arg($<args>[0][0]);
        $out.print(":=");
        self._arg($<args>[0][1]);
        $out.print(ss("",$semi))
    }
    method if_($/, Bool $semi = True) {
        $out.print("if (");
        self._arg($<args>[0][0]);
        self._arg($<args>[0][1]);
        self._arg($<args>[0][2]);
        $out.print(")\{");
        self.construct($/<args>[0][3]<arg><expr>, True);
        $out.print("}\n");
    }
    method else_($/, Bool $semi = True) {
        $out.print("else \{");
        self.construct($/<args>[0][0]<arg><expr>, True);
        $out.print("}\n");
    }
    method set($/, Bool $semi = True) {
        self._arg($<args>[0][0]);
        $out.print(":=");
        self._arg($<args>[0][1]);
        $out.print(ss("",$semi))
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
            } elsif $top<func> eq "if" {
                self.if_($top, $semi);
            } elsif $top<func> eq "else" {
                self.else_($top, $semi);
            } elsif $top<func> eq "sv" {
                self.set($top,$semi);
            }
            elsif %functions{$top<func>}:exists {
                if %functions{$top<func>} ne $top<args>[0].elems {
                    say "Incorrect argument count when calling $($top<func>)";
                    exit 1;
                }
                self.call($top, $semi);
            } elsif $top<func> eq "c" {} else {
                say "Unexpected token $top<func>";
                exit 1;
            }
        }
    }
    method TOP ($/) {
        $out = open $!outfile, :w;
        self.construct(make $/);
        $out.close();
    }
}