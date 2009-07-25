#!/usr/bin/env perl
use lib 't/lib';
use Test::IM::Engine tests => 9;

my @message;
my @plaintext;

sub incoming_callback {
    my $incoming = shift;

    my $plaintext = $incoming->plaintext;

    push @message,   $incoming->message;
    push @plaintext, $plaintext;

    $plaintext =~ tr[a-zA-Z][n-za-mN-ZA-M];

    return $incoming->reply($plaintext);
}

respond_ok('furrfu!' => 'sheesh!', 'no HTML still works fine');
is_deeply([splice @message],   ['furrfu!']);
is_deeply([splice @plaintext], ['furrfu!']);

respond_ok(
    '<HTML><FONT COLOR="red"><b>ACK!</b></FONT></HTML>' =>
    '<UGZY><SBAG PBYBE="erq"><o>NPX!</o></SBAG></UGZY>',
    'if you do not ask for HTML stripping, you do not get it',
);
is_deeply([splice @message],   ['<HTML><FONT COLOR="red"><b>ACK!</b></FONT></HTML>']);
is_deeply([splice @plaintext], ['<HTML><FONT COLOR="red"><b>ACK!</b></FONT></HTML>']);

respond_ok(
    htmlish('<HTML><FONT COLOR="red"><b>ACK!</b></FONT></HTML>'),
    'NPX!',
    'if you ask for HTML stripping, you get it!',
);
is_deeply([splice @message],   ['<HTML><FONT COLOR="red"><b>ACK!</b></FONT></HTML>']);
is_deeply([splice @plaintext], ['ACK!']);

