package IM::Engine::Outgoing;
use Moose;
use MooseX::StrictConstructor;

extends 'IM::Engine::Message';

has recipient => (
    is       => 'ro',
    isa      => 'IM::Engine::User',
    required => 1,
);

has incoming => (
    is        => 'ro',
    isa       => 'IM::Engine::Incoming',
    predicate => 'has_incoming',
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;

# Sartak is not at all outgoing!

__END__

=head1 NAME

IM::Engine::Outgoing - a message we're sending to somebody

=head1 ATTRIBUTES

=head2 recipient

An instance of L<IM::Engine::User> which represents the recipient of this
outgoing message.

=head2 incoming

An instance of L<IM::Engine::Incoming> to which this outgoing message was a
response. Since not all outgoing messages are replies, this attribute may have
no value; use the C<has_incoming> accessor to see whether it does.

=head2 message

See L<IM::Engine::Message/message>.

=head2 plaintext

See L<IM::Engine::Message/plaintext>.

=head1 SEE ALSO

=over 4

=item L<IM::Engine::Outgoing::IRC>

=item L<IM::Engine::Outgoing::Jabber>

=item L<IM::Engine::Incoming>

=item L<IM::Engine::Message> (the superclass)

=back

=cut

