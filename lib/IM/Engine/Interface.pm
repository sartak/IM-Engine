package IM::Engine::Interface;
use Moose;
use MooseX::StrictConstructor;
use MooseX::AttributeHelpers;

use IM::Engine::Incoming;
use constant incoming_class => 'IM::Engine::Incoming';

use IM::Engine::User;
use constant user_class => 'IM::Engine::User';

with 'IM::Engine::HasEngine';

has incoming_callback => (
    is        => 'rw',
    isa       => 'CodeRef',
    predicate => 'has_incoming_callback',
);

has credentials => (
    metaclass  => 'Collection::Hash',
    is         => 'ro',
    isa        => 'HashRef',
    default    => sub { {} },
    auto_deref => 1,
    provides   => {
        get    => 'credential',
        exists => 'has_credential',
    },
);

sub received_message {
    my $self     = shift;
    my $incoming = shift;

    return unless $self->has_incoming_callback;

    my $outgoing = eval { $self->incoming_callback->($incoming) };
    if ($@) {
        warn $@;
        $outgoing = $incoming->reply(
            message => "An error occurred. We apologize for the inconvenience.",
        );
    }

    # Should we warn if $outgoing is true but not an Outgoing?
    return unless blessed($outgoing)
               && $outgoing->isa('IM::Engine::Outgoing');

    $self->send_message($outgoing);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

