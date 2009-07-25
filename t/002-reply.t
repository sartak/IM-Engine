#!/usr/bin/env perl
use lib 't/lib';
use Test::IM::Engine tests => 1;

sub incoming_callback {
    my $incoming = shift;
    return $incoming->reply('pong!');
}

respond_ok('ping!' => 'pong!');

