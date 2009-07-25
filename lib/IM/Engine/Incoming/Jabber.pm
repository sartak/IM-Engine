package IM::Engine::Incoming::Jabber;
use Moose;
use MooseX::StrictConstructor;

extends 'IM::Engine::Incoming';

use IM::Engine::Outgoing::Jabber;
use constant _reply_class => 'IM::Engine::Outgoing::Jabber';

has xmpp_message => (
    is       => 'ro',
    isa      => 'AnyEvent::XMPP::IM::Message',
    required => 1,
);

augment _contextual_reply_arguments => sub {
    my $self = shift;

    return (
        xmpp_message => $self->xmpp_message->make_reply,
        inner,
    );
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

