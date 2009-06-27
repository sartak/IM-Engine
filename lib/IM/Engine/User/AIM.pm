package IM::Engine::User::AIM;
use Moose;

extends 'IM::Engine::User';

sub canonical_name {
    my $self = shift;
    my $name = lc $self->name;
    $name =~ s/\s+//g;
    return $name;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
