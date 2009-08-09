package IM::Engine::Plugin;
use Moose;
use MooseX::StrictConstructor;

with 'IM::Engine::HasEngine';

sub post_initialization { }

__PACKAGE__->meta->make_immutable;
no Moose;

1;

