package IM::Engine::Outgoing::IRC::Privmsg;
use Moose;
use MooseX::StrictConstructor;

extends 'IM::Engine::Outgoing';

__PACKAGE__->meta->make_immutable;
no Moose;

1;
