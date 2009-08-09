package IM::Engine::Interface::Jabber;
use Moose;
use MooseX::StrictConstructor;

use Scalar::Util 'weaken';
use AnyEvent;
use AnyEvent::XMPP::Client;

extends 'IM::Engine::Interface';

use IM::Engine::Incoming::Jabber;
use constant incoming_class => 'IM::Engine::Incoming::Jabber';

use IM::Engine::User::Jabber;
use constant user_class => 'IM::Engine::User::Jabber';

has xmpp => (
    is         => 'ro',
    isa        => 'AnyEvent::XMPP::Client',
    lazy_build => 1,
);

has accept_subscriptions => (
    is      => 'ro',
    isa     => 'Bool',
    default => 1,
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
    $xmpp->reg_cb(
        message => sub {
            my (undef, undef, $msg) = @_;

            return if !defined($msg->body);

            my $sender = $weakself->user_class->new_with_plugins(
                name   => $msg->from,
                engine => $weakself->engine,
            );

            my $incoming = $weakself->incoming_class->new_with_plugins(
                sender       => $sender,
                xmpp_message => $msg,
                message      => $msg->body,
                engine       => $weakself->engine,
            );

            $weakself->received_message($incoming);
        },
        contact_request_subscribe => sub {
            my (undef, undef, undef, $contact) = @_;

            return unless $self->accept_subscriptions;
            $contact->send_subscribed;
        },
    );
    weaken($weakself);

    return $xmpp;
}

sub send_message {
    my $self     = shift;
    my $outgoing = shift;

    if ($outgoing->isa('IM::Engine::Outgoing::Jabber') && $outgoing->has_xmpp_message) {
        my $xmpp_message = $outgoing->xmpp_message;

        $xmpp_message->add_body($outgoing->message);
        $xmpp_message->to($outgoing->recipient->name);

        $self->xmpp->send_message($xmpp_message);
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

