package Test::IM::Engine;
use strict;
use warnings;
use IM::Engine;
use base 'Test::More';

sub import {
    strict->import;
    warnings->import;
    goto \&Test::More::import;
}

1;

