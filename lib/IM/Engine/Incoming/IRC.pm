package IM::Engine::Incoming::IRC;
use Moose;
use MooseX::StrictConstructor;

extends 'IM::Engine::Incoming';

use IM::Engine::Outgoing::IRC;
use constant _reply_class => 'IM::Engine::Outgoing::IRC';

has irc_message => (
    is       => 'ro',
    isa      => 'HashRef',
    required => 1,
);

augment _contextual_reply_arguments => sub {
    my $self = shift;

    return (
        irc_message => $self->irc_message,
        inner,
    );
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

