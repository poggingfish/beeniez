unit module generator;
=begin overview
Beeniez codegen.
=end overview

use grammar;
use Terminal::ANSIColor;

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
    my $fptr = 0;
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
            $out.print("sub f$fptr\(");
            $fun_name = "$($<args>[0][0]<arg><string><str>)";
        } elsif !( $<args>[0][0]<arg><ident> ~~ Nil ) {
            $out.print("sub f$fptr\(");
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
        $fptr++;
        %functions{$fun_name} = [$argc, $fptr-1];
    }
    method call($/, Bool $semi = True) {
        my $func_name = %functions{$<func>};
        $out.print("f$($func_name[1])\(");
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
                if %functions{$top<func>}[0] ne $top<args>[0].elems {
                    say "Incorrect argument count when calling $($top<func>)";
                    exit 1;
                }
                self.call($top, $semi);
            } elsif $top<func> eq "use" {
                if ($top<args>[0][0]<arg><string> ~~ Nil) {
                    say "Use expected a string!";
                }
                my $fh = open "$($top<args>[0][0]<arg><string><str>)", :r;
                if !$fh {
                    say color('bold'), color('red'), "FATAL: Failed to import $($top<args>[0][0]<arg><string><str>)", color('reset');
                    exit 1;
                }
                my $g = language.new(:quiet, :colors, :lastrule);
                my $parsed = $g.parse($fh.slurp());
                if $g.error {
                    say "In included module $($top<args>[0][0]<arg><string><str>)";
                    say .report with $g.error;
                    exit 1;
                }
                self.construct(make $parsed);

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