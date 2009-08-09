package IM::Engine::Interface::Test;
use Moose;
use MooseX::StrictConstructor;
use MooseX::AttributeHelpers;

extends 'IM::Engine::Interface';

has outgoing => (
    metaclass => 'Collection::Array',
    is        => 'ro',
    isa       => 'ArrayRef[IM::Engine::Outgoing]',
    default   => sub { [] },
    provides  => {
        push   => 'send_message',
    },
);

sub run { confess "Do not call ->run in tests" }

sub splice_outgoing { splice @{ shift->outgoing } }

__PACKAGE__->meta->make_immutable;
no Moose;

1;

