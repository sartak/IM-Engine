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

my $sender = IM::Engine::User->new(
    name => 'test sender',
);

engine->interface->received_message(
    IM::Engine::Incoming->new(
        sender  => $sender,
        message => 'ping!',
    ),
);

is_deeply([engine->interface->splice_outgoing], [
    IM::Engine::Outgoing->new(
        recipient => $sender,
        message   => 'pong!',
        incoming  => IM::Engine::Incoming->new(
            sender  => $sender,
            message => 'ping!',
        ),
    ),
]);
