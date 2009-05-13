package IM::Interface::Incoming;
use Moose;

extends 'IM::Interface::Message';

has sender => (
    is       => 'ro',
    isa      => 'IM::Interface::User',
    required => 1,
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;
