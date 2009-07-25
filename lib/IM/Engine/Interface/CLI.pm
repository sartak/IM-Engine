package IM::Engine::Interface::CLI;
use Moose;
use MooseX::StrictConstructor;

extends 'IM::Engine::Interface';

sub send_message {
    my $self     = shift;
    my $outgoing = shift;

    print $outgoing->message . "\n";
}

sub run {
    my $self = shift;

    my $input = join ' ', @ARGV;

    my $incoming = $self->incoming_class->new(
        sender  => $self->user_class->new(name => $ENV{USER}),
        message => $input,
    );

    $self->received_message($incoming);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

