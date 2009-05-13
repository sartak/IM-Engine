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

    my $outgoing = $self->_reply_class->new(%args);
    $self->_contextualize_reply($outgoing);

    return $outgoing;
}

sub _contextualize_reply {
    my $self     = shift;
    my $outgoing = shift;

    $outgoing->_set_recipient($self->sender);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
