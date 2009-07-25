package IM::Engine::Plugin;
use Moose;
use MooseX::StrictConstructor;

with 'IM::Engine::HasEngine';

__PACKAGE__->meta->make_immutable;

1;

