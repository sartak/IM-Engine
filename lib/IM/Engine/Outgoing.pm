package IM::Engine::Outgoing;
use Moose;

extends 'IM::Engine::Message';

has recipient => (
    is       => 'ro',
    writer   => '_set_recipient',
    isa      => 'IM::Engine::User',
    required => 1,
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;
