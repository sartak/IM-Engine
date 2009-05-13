package IM::Engine;
use Moose;
use Moose::Util::TypeConstraints;

coerce 'IM::Engine::Interface'
    => from 'HashRef'
    => via {
        my $protocol = delete $_->{protocol}
            or die "Your IM::Engine::Interface definition must include the 'protocol' key.";

        if ($protocol !~ s{^\+}{}) {
            $protocol = join '::', 'IM', 'Engine', 'Interface', $protocol;
        }

        Class::MOP::load_class($protocol);

        return $protocol->new($_);
    };

has interface => (
    is       => 'ro',
    isa      => 'IM::Engine::Interface',
    required => 1,
    coerce   => 1,
    handles  => ['run'],
);

__PACKAGE__->meta->make_immutable;
no Moose;
no Moose::Util::TypeConstraints;

1;

