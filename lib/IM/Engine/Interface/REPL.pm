package IM::Engine::Interface::REPL;
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

    while (1) {
        my $input = do {
            local $| = 1;
            print "> ";
            <STDIN>;
        };
        last if !defined($input);
        chomp $input;

        my $sender = $self->user_class->new_with_plugins(
            name   => $ENV{USER},
            engine => $self->engine,
        );

        my $incoming = $self->incoming_class->new_with_plugins(
            sender  => $sender,
            message => $input,
            engine  => $self->engine,
        );

        $self->received_message($incoming);
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

