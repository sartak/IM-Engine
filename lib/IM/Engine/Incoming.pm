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
