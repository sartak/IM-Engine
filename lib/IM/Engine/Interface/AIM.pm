package IM::Engine::Interface::AIM;
use Moose;
use MooseX::StrictConstructor;

use Scalar::Util 'weaken';
use Net::OSCAR;

extends 'IM::Engine::Interface';

use IM::Engine::User::AIM;
use constant user_class => 'IM::Engine::User::AIM';

has oscar => (
    is      => 'ro',
    isa     => 'Net::OSCAR',
    lazy    => 1,
    builder => '_build_oscar',
);

has signed_on => (
    is      => 'ro',
    writer  => '_set_signed_on',
    isa     => 'Bool',
    default => 0,
);

sub _build_oscar {
    my $self = shift;

    my $oscar = Net::OSCAR->new;

    my $weakself = $self;
    $oscar->set_callback_im_in(sub {
        my (undef, $screenname, $message, $is_away) = @_;

        my $sender = $weakself->user_class->new_with_plugins(
            name   => $screenname->stringify,
            engine => $weakself->engine,
        );

        my $incoming = $weakself->incoming_class->new_with_plugins(
            traits  => ['HTMLish'],
            sender  => $sender,
            message => $message,
            engine  => $weakself->engine,
        );

        $weakself->received_message($incoming);
    });

    $oscar->set_callback_signon_done(sub {
        $weakself->_set_signed_on(1);
    });

    weaken($weakself);

    $oscar->signon($self->credentials);

    return $oscar;
}

sub send_message {
    my $self     = shift;
    my $outgoing = shift;

    $self->_wait_until_signed_on unless $self->signed_on;

    $self->oscar->send_im($outgoing->recipient->name, $outgoing->message);
    $self->oscar->do_one_loop; # make sure we send the message
}

sub run {
    my $self = shift;
    while (1) {
        $self->oscar->do_one_loop;
    }
}

sub _wait_until_signed_on {
    my $self = shift;

    while (1) {
        $self->oscar->do_one_loop;
        last if $self->signed_on;
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

