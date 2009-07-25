package IM::Engine::Outgoing::IRC;
use Moose;
use MooseX::StrictConstructor;

extends 'IM::Engine::Outgoing';

has irc_message => (
    is        => 'ro',
    isa       => 'HashRef',
    predicate => 'has_irc_message',
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;

