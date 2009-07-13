package IM::Engine::Interface::Test;
use Moose;
use MooseX::AttributeHelpers;

extends 'IM::Engine::Interface';

has outgoing => (
    metaclass => 'Collection::Array',
    is        => 'ro',
    isa       => 'ArrayRef[IM::Outgoing]',
    provides  => {
        push   => 'send_message',
        splice => 'splice_outgoing',
    },
);

sub run { confess "Do not call ->run in tests" }

__PACKAGE__->meta->make_immutable;
no Moose;

1;


