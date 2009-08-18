package IM::Engine::Interface::IRC;
use Moose;
use MooseX::StrictConstructor;

use Scalar::Util 'weaken';

use AnyEvent;
use AnyEvent::IRC::Client;

extends 'IM::Engine::Interface';

use IM::Engine::Incoming::IRC;
use constant incoming_class => 'IM::Engine::Incoming::IRC';

has irc => (
    is         => 'ro',
    lazy_build => 1,

    # The type of AnyEvent::IRC::Client
    #isa        => 'AnyEvent::IRC::Client',
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

        my $nick = $ircmsg->{prefix} =~ /^([^!]+?)/;
        my $text = $ircmsg->{params}[1];

        my $sender = $weakself->user_class->new_with_plugins(
            name   => $nick,
            engine => $weakself->engine,
        );

        my $incoming = $weakself->incoming_class->new_with_plugins(
            sender  => $sender,
            channel => $channel,
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
}

sub _channels {
    my $self = shift;

    return grep { defined }
           $self->credential('channel'),
           @{ $self->credential('channels') || [] };
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

