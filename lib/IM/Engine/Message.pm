package IM::Engine::Message;
use Moose;

has message => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;
