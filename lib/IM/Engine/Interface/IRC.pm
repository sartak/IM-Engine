package IM::Engine::Interface::IRC;
use Moose;
use MooseX::StrictConstructor;

use Scalar::Util 'weaken';

use IM::Engine::Interface::IRC::Bot;

extends 'IM::Engine::Interface';

use IM::Engine::Incoming::IRC;
use constant incoming_class => 'IM::Engine::Incoming::IRC';

has bot => (
    is         => 'ro',
    isa        => 'IM::Engine::Interface::IRC::Bot',
    lazy_build => 1,
    handles    => ['run'],
);

sub _build_bot {
    my $self = shift;
    my $weakself = $self;

    my $bot = IM::Engine::Interface::IRC::Bot->new(
        im_interface => $weakself,
        $self->credentials,
    );

    weaken($weakself);

    return $bot;
}

sub said {
    my $self = shift;
    my $msg  = shift;

    my $incoming = $self->incoming_class->new(
        sender      => $self->user_class->new(name => $msg->{who}),
        message     => $msg->{body},
        irc_message => $msg,
    );
    $self->received_message($incoming);
}

sub send_message {
    my $self     = shift;
    my $outgoing = shift;

    if ($outgoing->isa('IM::Engine::Outgoing::IRC') && $outgoing->has_irc_message) {
        $self->bot->say(
            %{ $outgoing->irc_message },
            body => $outgoing->message,
        );
    }
    else {
        die "Your outgoing message must be a subclass of IM::Engine::Outgoing::IRC";
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

