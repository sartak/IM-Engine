package IM::Engine::Outgoing::IRC;
use Moose;
use MooseX::StrictConstructor;

extends 'IM::Engine::Outgoing';

has command => (
    is        => 'ro',
    isa       => 'Str',
    default   => 'PRIVMSG',
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;
