#!/usr/bin/env perl
use lib 't/lib';
use diagnostics;
use Test::IM::Engine tests => 9;

my @message;
my @plaintext;

sub incoming_callback {
    my $incoming = shift;

    push @message, $incoming->message;
    push @plaintext, $incoming->plaintext;

    my $plaintext = $incoming->plaintext;
    $plaintext =~ tr[a-zA-Z][n-za-mN-ZA-M];

    return $incoming->reply($plaintext);
}

# Make sure that "plaintext" works {{{
my $sender = IM::Engine::User->new(
    name => 'test sender',
);

engine->interface->received_message(
    IM::Engine::Incoming->new(
        sender  => $sender,
        message => 'furrfu!',
    ),
);

is_deeply([engine->interface->splice_outgoing], [
    IM::Engine::Outgoing->new(
        recipient => $sender,
        message   => 'sheesh!',
        incoming  => IM::Engine::Incoming->new(
            sender    => $sender,
            message   => 'furrfu!',
            plaintext => 'furrfu!',
        ),
    ),
]);

is_deeply([splice @message],   ['furrfu!']);
is_deeply([splice @plaintext], ['furrfu!']);

# }}}
# Make sure that HTML is not stripped automatically {{{
engine->interface->received_message(
    IM::Engine::Incoming->new(
        sender  => $sender,
        message => '<HTML><FONT COLOR="red"><b>ACK!</b></FONT></HTML>',
    ),
);

is_deeply([engine->interface->splice_outgoing], [
    IM::Engine::Outgoing->new(
        recipient => $sender,
        message   => '<UGZY><SBAG PBYBE="erq"><o>NPX!</o></SBAG></UGZY>',
        incoming  => IM::Engine::Incoming->new(
            sender    => $sender,
            message   => '<HTML><FONT COLOR="red"><b>ACK!</b></FONT></HTML>',
            plaintext => '<HTML><FONT COLOR="red"><b>ACK!</b></FONT></HTML>',
        ),
    ),
]);

is_deeply([splice @message],   ['<HTML><FONT COLOR="red"><b>ACK!</b></FONT></HTML>']);
is_deeply([splice @plaintext], ['<HTML><FONT COLOR="red"><b>ACK!</b></FONT></HTML>']);
# }}}
# Make sure that HTML IS stripped on demand {{{
engine->interface->received_message(
    IM::Engine::Incoming->new_with_traits(
        traits  => ['HTMLish'],
        sender  => $sender,
        message => '<HTML><FONT COLOR="red"><b>ACK!</b></FONT></HTML>',
    ),
);

# Using anonymous metaclasses introduces a __MOP__ key in the instance
is_deeply([map { delete $_->{incoming}{__MOP__}; $_ } engine->interface->splice_outgoing], [
    IM::Engine::Outgoing->new(
        recipient => $sender,
        message   => 'NPX!',
        incoming  => IM::Engine::Incoming->new(
            sender    => $sender,
            message   => '<HTML><FONT COLOR="red"><b>ACK!</b></FONT></HTML>',
            plaintext => 'ACK!',
        ),
    ),
]);

is_deeply([splice @message],   ['<HTML><FONT COLOR="red"><b>ACK!</b></FONT></HTML>']);
is_deeply([splice @plaintext], ['ACK!']);
# }}}

