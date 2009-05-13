package IM::Engine::User::AIM;
use Moose;

extends 'IM::Engine::User';

sub canonical_name {
    my $self = shift;
    return lc $self->name;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
