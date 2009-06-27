package IM::Engine;
use Moose;
use Moose::Util::TypeConstraints;

use IM::Engine::Interface;

our $VERSION = '0.01';

with 'IM::Engine::HasPlugins';

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

IM::Engine - The HTTP::Engine of instant messaging

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


=head1 AUTHOR

Shawn M Moore, C<sartak@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2009 Shawn M Moore.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

