#!/usr/bin/env raku

my $rc = IO::Path.new(%*ENV{"HOME"}~"/.beeniez/beeniezrc.raku");
if $rc.e {
    require $rc;
} else {
    say "No beeniezrc.";
    exit 1;
}
try {
    run "raku", %*ENV{"__BEENIEZ_PATH"}~"/sources/beeniez.raku", @*ARGS;
}