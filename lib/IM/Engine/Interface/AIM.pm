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
        my (undef, $from, $message, $is_away) = @_;
        $weakself->received_message(
            from    => $from,
            message => $message,
        );
    });

    $oscar->signon($self->credentials);

    return $oscar;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
