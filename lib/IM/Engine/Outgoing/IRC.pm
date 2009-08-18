package IM::Engine::Outgoing::IRC;
use Moose;
use MooseX::StrictConstructor;

extends 'IM::Engine::Outgoing';

has channel => (
    is        => 'ro',
    isa       => 'Str',
    predicate => 'has_channel',
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;

