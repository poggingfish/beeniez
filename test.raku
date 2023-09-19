#!/usr/bin/env raku

constant $major = "1";
constant $minor = "0";

my %tests;
sub make_test($file, $expected) {
    %tests{$file} = $expected;
}
sub run_tests($suppress_passed) {
    my $fail = 0;
    my $pass = 0;
    for %tests.keys -> $test {
        my $result = run "beeniez", "--run", "$test", :out, :err;
        if ($result.out.slurp(:close) eq %tests{$test} and $result.err.slurp(:close) eq "") {
            if !$suppress_passed {
                say "[$($fail+$pass+1)/$(%tests.elems)] $test \e[0;32mpassed!";
            }
            $pass++;
        } else {
            say "[$($fail+$pass+1)/$(%tests.elems)] $test \e[1;31mfailed!";
            $fail++;
        }
        print("\e[0m");
    }
    say "$pass/$($pass+$fail) tests passed."
}

sub MAIN(Bool :$suppress, #= Suppress passes.
         Bool :$v #= Displays the version of the version of the test suite.
    ) {
    if $v {
        say "Beeniez Test Suite $major.$minor";
        exit 0;
    }
    make_test("SRC/func.bnz","3\n");
    make_test("SRC/if.bnz","Equal!\nNot equal!\n");
    make_test("SRC/num.bnz","10\n");
    make_test("SRC/var.bnz","9\n");
    make_test("SRC/comment.bnz","I am not a comment\n");
    make_test("SRC/unicode.bnz","73\n");
    make_test("SRC/use.bnz","6\n");
    make_test("SRC/array.bnz","10\n");
    make_test("SRC/pyramid.bnz","*\n**\n***\n****\n");
    make_test("SRC/std/strlist_map.bnz","[3,5,7]\n");
    make_test("SRC/std/pushpop.bnz","2\n");
    make_test("SRC/std/isType.bnz","1\n0\n1\n1\n");
    make_test("SRC/std/file.bnz","sup!\n");
    run_tests($suppress);
}