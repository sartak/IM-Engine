#!/usr/bin/env perl
use lib 't/lib';
use Test::IM::Engine tests => 1;

sub incoming_callback {
    my $incoming = shift;
    return IM::Engine::Outgoing->new(
        recipient => $incoming->sender,
        message   => 'pong!',
        incoming  => $incoming,
    );
}

respond_ok('ping!' => 'pong!');

