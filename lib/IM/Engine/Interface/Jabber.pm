package IM::Engine::Interface::Jabber;
use Moose;
use Scalar::Util 'weaken';
use AnyEvent::XMPP::Client;

extends 'IM::Engine::Interface';

has xmpp => (
    is         => 'ro',
    isa        => 'AnyEvent::XMPP::Client',
    lazy_build => 1,
);

sub _build_xmpp {
    my $self = shift;
    my $xmpp = AnyEvent::XMPP::Client->new;

    $xmpp->add_account(
        $self->credential('jid'),
        $self->credential('password'),
        $self->credential('host'),
        $self->credential('port'),
        $self->credential('connection_args'),
    );

    my $weakself = $self;
    $xmpp->reg_cb(message => sub {
        my (undef, $msg) = @_;

        my $incoming = IM::Engine::Incoming->new(
            sender  => $weakself->user_class->new(name => $msg->from),
            message => $msg->body,
        );

        $weakself->received_message($incoming);
    });
    weaken($weakself);

    $xmpp->start;

    return $xmpp;
}

sub send_message {
    my $self     = shift;
    my $outgoing = shift;

    $self->xmpp->send_message(
        $outgoing->message,
        $outgoing->recipient,
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
