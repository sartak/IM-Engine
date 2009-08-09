package IM::Engine::Message;
use Moose;
use MooseX::StrictConstructor;

use IM::Engine::ExtendsObject::Message;
with 'IM::Engine::PluggableConstructor' => {
    role_specifier => '+IM::Engine::ExtendsObject::Message',
};

has '+_trait_namespace' => (default => __PACKAGE__);

has message => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has plaintext => (
    is       => 'ro',
    isa      => 'Str',
    lazy     => 1,
    builder  => '_build_plaintext',
);

sub _build_plaintext { shift->message }

__PACKAGE__->meta->make_immutable;
no Moose;

1;

__END__

=head1 NAME

IM::Engine::Message - an instant message, IRC line, etc.

=head1 SYNOPSIS

    my $message = ...;

    print $message->message;

    print $message->plaintext;

=head1 ATTRIBUTES

=head2 message

The exact message that this object encapsulates.

=head2 plaintext

The message that this object encapsulates but with any formatting stripped. For example, if this message represents an AIM IM, HTML will be stripped from the C<plaintext>.

=head1 SEE ALSO

=over 4

=item L<IM::Engine::Message::HTMLish>

=item L<IM::Engine::Incoming>

=item L<IM::Engine::Outgoing>

=back

=cut

