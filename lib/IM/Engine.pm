package IM::Engine;
use Moose;

has interface => (
    is       => 'ro',
    isa      => 'IM::Engine::Interface',
    required => 1,
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;

