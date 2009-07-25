package Test::IM::Engine;
use strict;
use warnings;
use IM::Engine;
use base 'Test::More';

sub import_extra {
    Test::More->export_to_level(2);
    strict->import;
    warnings->import;
}

1;

