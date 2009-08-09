package IM::Engine::Incoming;
use Moose;
use MooseX::StrictConstructor;

extends 'IM::Engine::Message';

use IM::Engine::Outgoing;
use constant _reply_class => 'IM::Engine::Outgoing';

has sender => (
    is       => 'ro',
    isa      => 'IM::Engine::User',
    required => 1,
);

sub reply {
    my $self = shift;
    my %args;

    if (@_ == 1) {
        %args = (message => $_[0]);
    }
    else {
        %args = @_;
    }

    Carp::carp("Incoming->reply constructs an Outgoing object for you; it does not automatically send it") if !defined(wantarray);

    my $outgoing = $self->_reply_class->new(
        $self->_contextual_reply_arguments,
        %args,
    );

    return $outgoing;
}

sub _contextual_reply_arguments {
    my $self = shift;

    return (
        incoming  => $self,
        recipient => $self->sender,
        inner,
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

__END__

=head1 NAME

IM::Engine::Incoming - a message we have received

=head1 ATTRIBUTES

=head2 sender

An instance of L<IM::Engine::User> which represents the sender of this incoming
message.

=head2 message

See L<IM::Engine::Message/message>.

=head2 plaintext

See L<IM::Engine::Message/plaintext>.

=head1 METHODS

=head2 reply

Constructs a L<IM::Engine::Outgoing> message that represents a reply to this
incoming message.

    my $outgoing = $incoming->reply("Sorry, I didn't understand.");

You can also pass in a hash of attributes for constructing the outgoing
message.

=head1 SEE ALSO

=over 4

=item L<IM::Engine::Incoming::IRC>

=item L<IM::Engine::Incoming::Jabber>

=item L<IM::Engine::Outgoing>

=item L<IM::Engine::Message> (the superclass)

=cut

