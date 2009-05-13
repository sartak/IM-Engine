package IM::Engine::Outgoing::Jabber;
use Moose;

extends 'IM::Engine::Outgoing';

has xmpp_message => (
    is        => 'ro',
    writer    => '_set_xmpp_message',
    isa       => 'AnyEvent::XMPP::IM::Message',
    predicate => 'has_xmpp_message',
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;

