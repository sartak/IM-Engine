#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
BEGIN {
    eval "use IPC::System::Simple qw(capturex)";
    plan skip_all => "IPC::System::Simple is required for this test" if $@;
    plan tests => 2;
}

use FindBin '$Bin';

sub cli_is {
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my $input    = shift;
    my $expected = shift;
    my $name     = shift;

    my $got = capturex($^X, "$Bin/bin/test-cli.pl", $input);
    chomp $got;

    is($got, $expected, $name);
}

cli_is("sheesh", "furrfu");
cli_is("sheesh\nfurrfu", "furrfu\nsheesh");

