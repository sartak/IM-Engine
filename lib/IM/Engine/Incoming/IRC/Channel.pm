package IM::Engine::Incoming::IRC::Channel;
use Moose;
use MooseX::StrictConstructor;

extends 'IM::Engine::Incoming';

use IM::Engine::Outgoing::IRC::Channel;
use constant _reply_class => 'IM::Engine::Outgoing::IRC::Channel';

has channel => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

augment _contextual_reply_arguments => sub {
    my $self = shift;

    return (
        channel => $self->channel,
        inner,
    );
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

