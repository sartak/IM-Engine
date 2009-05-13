package IM::Engine::Incoming;
use Moose;

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
    my %args = @_;

    my $outgoing = $self->_reply_class->new(
        $self->_contextual_reply_arguments,
        %args,
    );

    return $outgoing;
}

sub _contextual_reply_arguments {
    my $self = shift;

    return (
        recipient => $self->sender,
        inner,
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
