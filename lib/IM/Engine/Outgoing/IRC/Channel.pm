package IM::Engine::Outgoing::IRC::Channel;
use Moose;
use MooseX::StrictConstructor;

extends 'IM::Engine::Outgoing';

has channel => (
    is        => 'ro',
    isa       => 'Str',
    predicate => 'has_channel',
);

has '+recipient' => (
    required => 0,
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;

