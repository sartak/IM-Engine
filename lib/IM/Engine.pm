package IM::Engine;
use Moose;
use Moose::Util::TypeConstraints;

use IM::Engine::Interface;

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

__END__

=head1 NAME

IM::Engine - An HTTP::Engine for instant messaging

=head1 SYNOPSIS

    IM::Engine->new(
        interface => {
            protocol => 'AIM',
            credentials => {
                screenname => '...',
                password   => '...',
            },
            incoming_callback => sub {
                my $incoming = shift;

                my $message = $incoming->message;
                $message =~ tr[a-zA-Z][n-za-mN-ZA-M];

                return $incoming->reply(
                    message => $message,
                );
            },
        },
    )->run;

=head1 DESCRIPTION


=cut

