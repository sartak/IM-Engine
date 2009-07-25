package IM::Engine::User;
use Moose;
use MooseX::StrictConstructor;

has name => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

sub canonical_name {
    my $self = shift;
    return $self->name;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
