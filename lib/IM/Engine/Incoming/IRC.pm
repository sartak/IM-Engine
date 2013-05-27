package IM::Engine::Incoming::IRC;
use Moose;
use MooseX::StrictConstructor;

extends 'IM::Engine::Incoming';

use IM::Engine::Outgoing::IRC::Channel;

has command => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;
