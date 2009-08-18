package IM::Engine::Interface::IRC;
use Moose;
use MooseX::StrictConstructor;

use Scalar::Util 'weaken';

use AnyEvent;
use AnyEvent::IRC::Client;
use AnyEvent::IRC::Util 'prefix_nick';

extends 'IM::Engine::Interface';

use IM::Engine::Incoming::IRC::Channel;
use constant incoming_channel_class => 'IM::Engine::Incoming::IRC::Channel';

use IM::Engine::Incoming::IRC::Privmsg;
use constant incoming_privmsg_class => 'IM::Engine::Incoming::IRC::Privmsg';

has irc => (
    is         => 'ro',
    isa        => 'AnyEvent::IRC::Client',
    lazy_build => 1,
);

sub _build_irc {
    my $self = shift;
    my $irc = AnyEvent::IRC::Client->new;

    my $weakself = $self;

    $irc->reg_cb(registered => sub {
        my $irc = shift;
        $irc->send_srv('JOIN', $_) for $weakself->_channels;
    });

    $irc->reg_cb(publicmsg => sub {
        my $irc     = shift;
        my $channel = shift;
        my $ircmsg  = shift;

        my $nick = prefix_nick($ircmsg->{prefix});
        my $text = $ircmsg->{params}[1];

        my $sender = $weakself->user_class->new_with_plugins(
            name   => $nick,
            engine => $weakself->engine,
        );

        my $incoming = $weakself->incoming_channel_class->new_with_plugins(
            sender  => $sender,
            channel => $channel,
            message => $text,
            engine  => $weakself->engine,
        );

        $weakself->received_message($incoming);
    });

    $irc->reg_cb(privatemsg => sub {
        my $irc       = shift;
        my $recipient = shift;
        my $ircmsg    = shift;

        return if $recipient eq 'AUTH';

        my $nick = prefix_nick($ircmsg->{prefix});
        my $text = $ircmsg->{params}[1];

        my $sender = $weakself->user_class->new_with_plugins(
            name   => $nick,
            engine => $weakself->engine,
        );

        my $incoming = $weakself->incoming_privmsg_class->new_with_plugins(
            sender  => $sender,
            message => $text,
            engine  => $weakself->engine,
        );

        $weakself->received_message($incoming);
    });

    weaken($weakself);

    $irc->connect(
        $self->credential('server'),
        $self->credential('port'),
        {
            nick     => $self->credential('nick'),
            user     => $self->credential('username'),
            real     => $self->credential('realname'),
            password => $self->credential('server_password'),
        },
    );

    return $irc;
}

sub _channels {
    my $self = shift;

    return grep { defined }
           $self->credential('channel'),
           @{ $self->credential('channels') || [] };
}

sub send_message {
    my $self     = shift;
    my $outgoing = shift;

    if ($outgoing->isa('IM::Engine::Outgoing::IRC::Channel')) {
        my $channel = $outgoing->channel;
        $self->irc->send_chan($channel, 'PRIVMSG', $channel, $outgoing->message);
    }
    else {
        $self->irc->send_msg('PRIVMSG', $outgoing->recipient->name, $outgoing->message);
    }
}

sub run {
   my $self = shift;

   my $j = AnyEvent->condvar;
   $self->irc; # force load
   $j->wait;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

