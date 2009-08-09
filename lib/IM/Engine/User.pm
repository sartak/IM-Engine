package IM::Engine::User;
use Moose;
use MooseX::StrictConstructor;

use IM::Engine::ExtendsObject::User;
with 'IM::Engine::PluggableConstructor' => {
    role_specifier => '+IM::Engine::ExtendsObject::User',
};

has '+_trait_namespace' => (default => __PACKAGE__);

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

__END__

=head1 NAME

IM::Engine::User - a user that we're IMing

=head1 ATTRIBUTES

=head2 name

The verbatim screenname (or nickname or jid or ...) of the user.

=head1 METHODS

=head2 canonical_name

This method returns the name but with "arbitrary stuff" removed. This is more
useful for storing the name in a database, or for comparing names.

While documenting this method it gave me a bad feeling, so it very well may go
away. C<:)>

=head1 SEE ALSO

=over 4

=item L<IM::Engine::User::AIM>

=item L<IM::Engine::User::Jabber>

=back

=cut

