#!/usr/bin/env raku
mkdir %*ENV{"HOME"}~"/.beeniez/";
my $rc = IO::Path.new(%*ENV{"HOME"}~"/.beeniez/beeniezrc.raku");
if !$rc.e {
    say "No beeniezrc. Creating now!";
    my $rc_file = open $rc, :w;
    $rc_file.print("%*ENV\{\"__BEENIEZ_PATH\"\} = \"$*CWD\";");
}
say "launch.raku -> ~/.beeniez/beeniez";
copy "launch.raku", %*ENV{"HOME"}~"/.beeniez/beeniez";

say "\e[1;31mAdd \""~%*ENV{"HOME"}~"/.beeniez/beeniez\" to your PATH to run it from anywhere.\e[0m
You can add it to PATH by putting
export PATH=\"\$PATH:"~%*ENV{"HOME"}~"/.beeniez/\"
in your ~/.bashrc or whatever your current shell uses.";