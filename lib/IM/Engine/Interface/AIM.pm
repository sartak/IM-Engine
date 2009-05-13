package IM::Engine::Interface::AIM;
use Moose;
use Scalar::Util 'weaken';

extends 'IM::Engine::Interface';

has oscar => (
    is      => 'ro',
    isa     => 'Net::OSCAR',
    lazy    => 1,
    builder => '_build_oscar',
);

sub _build_oscar {
    my $self = shift;

    my $oscar = Net::OSCAR->new;

    my $weakself = $self;
    weaken($weakself);

    $oscar->set_callback(sub {
        my (undef, $sender, $message, $is_away) = @_;

        my $incoming = IM::Engine::Incoming->new(
            sender  => IM::Engine::User->new(username => $sender),
            message => $message,
        );

        $weakself->received_message($incoming);
    });

    $oscar->signon($self->credentials);

    return $oscar;
}

sub run {
    my $self = shift;
    while (1) {
        $self->oscar->do_one_loop;
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
