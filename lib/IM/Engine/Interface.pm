package IM::Engine::Interface;
use Moose;

has incoming_callback => (
    is        => 'ro',
    isa       => 'CodeRef',
    predicate => 'has_incoming_callback',
);

has credentials => (
    is         => 'ro',
    isa        => 'HashRef',
    default    => sub { {} },
    auto_deref => 1,
);

has user_class => (
    is      => 'ro',
    isa     => 'IM::Engine::User',
    default => 'IM::Engine::User',
);

sub received_message {
    my $self     = shift;
    my $incoming = shift;

    return unless $self->has_incoming_callback;

    my $outgoing = $self->incoming_callback->($incoming);

    # Should we warn if $outgoing is true but not an Outgoing?
    return unless blessed($outgoing)
               && $outgoing->isa('IM::Engine::Outgoing');

    $self->send_message($outgoing);
}

sub send_message {
    my $class = blessed($_[0]) || $_[0];
    die "The send_message method must be defined by the $class class";
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
