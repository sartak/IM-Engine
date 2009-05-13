package IM::Engine::Incoming::Jabber;
use Moose;

extends 'IM::Engine::Incoming';

use IM::Engine::Outgoing::Jabber;
use constant _reply_class => 'IM::Engine::Outgoing::Jabber';

has xmpp_message => (
    is       => 'ro',
    isa      => 'AnyEvent::XMPP::IM::Message',
    required => 1,
);

after _contextualize_reply => sub {
    my $self     = shift;
    my $outgoing = shift;

    $outgoing->_set_xmpp_message($self->xmpp_message);
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

