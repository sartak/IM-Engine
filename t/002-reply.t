#!/usr/bin/env perl
use strict;
use warnings;
use IM::Engine;
use Test::More tests => 1;

my $engine = IM::Engine->new(
    interface => {
        protocol => 'Test',
        incoming_callback => sub {
            my $incoming = shift;
            return $incoming->reply('pong!');
        },
    },
);

my $sender = IM::Engine::User->new(
    name => 'test sender',
);

$engine->interface->received_message(
    IM::Engine::Incoming->new(
        sender  => $sender,
        message => 'ping!',
    ),
);

is_deeply([$engine->interface->splice_outgoing], [
    IM::Engine::Outgoing->new(
        recipient => $sender,
        message   => 'pong!',
        incoming  => IM::Engine::Incoming->new(
            sender  => $sender,
            message => 'ping!',
        ),
    ),
]);
