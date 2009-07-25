package IM::Engine::User::Jabber;
use Moose;
use MooseX::StrictConstructor;

extends 'IM::Engine::User';

sub canonical_name {
    my $self = shift;

    my $name = lc $self->name;

    # Strip resource
    $name =~ s{/.*}{};

    return $name;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

