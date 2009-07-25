package IM::Engine::Outgoing;
use Moose;
use MooseX::StrictConstructor;

extends 'IM::Engine::Message';

has recipient => (
    is       => 'ro',
    isa      => 'IM::Engine::User',
    required => 1,
);

has incoming => (
    is        => 'ro',
    isa       => 'IM::Engine::Incoming',
    predicate => 'has_incoming',
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;
