package IM::Engine::Interface::Jabber;
use Moose;
use Scalar::Util 'weaken';
use AnyEvent;
use AnyEvent::XMPP::Client;

extends 'IM::Engine::Interface';

use IM::Engine::Incoming::Jabber;
use constant incoming_class => 'IM::Engine::Incoming::Jabber';

has xmpp => (
    is         => 'ro',
    isa        => 'AnyEvent::XMPP::Client',
    lazy_build => 1,
);

sub _build_xmpp {
    my $self = shift;
    my $xmpp = AnyEvent::XMPP::Client->new;

    $xmpp->add_account(
        $self->credential('jid'),
        $self->credential('password'),
        $self->credential('host'),
        $self->credential('port'),
        $self->credential('connection_args'),
    );

    my $weakself = $self;
    $xmpp->reg_cb(message => sub {
        my (undef, $msg) = @_;

        my $incoming = $weakself->incoming_class->new(
            sender  => $weakself->user_class->new(name => $msg->from),
            message => $msg->body,
        );

        $weakself->received_message($incoming);
    });
    weaken($weakself);

    $xmpp->start;

    return $xmpp;
}

sub send_message {
    my $self     = shift;
    my $outgoing = shift;

    if ($self->outgoing->isa('IM::Engine::Outgoing::Jabber') && $self->outgoing->has_xmpp_message) {
        my $xmpp_message = $self->outgoing->xmpp_message;
        $xmpp_message->add_body($outgoing->message);
        $self->xmpp_send_message($xmpp_message);
    }
    else {
        $self->xmpp->send_message(
            $outgoing->message,
            $outgoing->recipient->name,
        );
    }
}

sub run {
   my $self = shift;

   my $j = AnyEvent->condvar;
   $self->xmpp->start;
   $j->wait;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
