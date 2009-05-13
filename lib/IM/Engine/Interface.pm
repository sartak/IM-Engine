package IM::Engine::Interface;
use Moose;

has incoming_callback => (
    is        => 'ro',
    isa       => 'CodeRef',
    predicate => 'has_incoming_callback',
);

has credentials => (
    is         => 'ro',
    isa        => 'HashRef',
    default    => sub { {} },
    auto_deref => 1,
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;
