#!/usr/bin/env perl
use lib 't/lib';
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

respond_ok('furrfu!' => 'sheesh!');
is_deeply([splice @message],   ['furrfu!']);
is_deeply([splice @plaintext], ['furrfu!']);

respond_ok(
    '<HTML><FONT COLOR="red"><b>ACK!</b></FONT></HTML>' =>
    '<UGZY><SBAG PBYBE="erq"><o>NPX!</o></SBAG></UGZY>',
);
is_deeply([splice @message],   ['<HTML><FONT COLOR="red"><b>ACK!</b></FONT></HTML>']);
is_deeply([splice @plaintext], ['<HTML><FONT COLOR="red"><b>ACK!</b></FONT></HTML>']);

respond_ok(
    IM::Engine::Incoming->new_with_traits(
        traits  => ['HTMLish'],
        sender  => sender,
        message => '<HTML><FONT COLOR="red"><b>ACK!</b></FONT></HTML>',
    ) => 'NPX!',
);
is_deeply([splice @message],   ['<HTML><FONT COLOR="red"><b>ACK!</b></FONT></HTML>']);
is_deeply([splice @plaintext], ['ACK!']);

