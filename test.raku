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
        my $result = run "sources/beeniez.raku", "--run", "$test", :out, :err;
        if ($result.out.slurp(:close) eq %tests{$test} and $result.err.slurp(:close) eq "") {
            if !$suppress_passed {
                say "Test $test passed!";
            }
            $pass++;
        } else {
            say "Test $test failed!";
            $fail++;
        }
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
    make_test("legacy/SRC/EXPR.WEIN","-2\n");
    make_test("legacy/SRC/HI.WEIN","HI.\n");
    make_test("legacy/SRC/NUM.WEIN","10\n");
    make_test("legacy/SRC/VAR.WEIN","9\n");
    make_test("legacy/SRC/FUNC.WEIN","5\n1\n");
    make_test("SRC/comment.bnz","I am not a comment\n");
    make_test("SRC/unicode.bnz","73\n");
    make_test("SRC/use.bnz","6\n");
    run_tests($suppress);
}