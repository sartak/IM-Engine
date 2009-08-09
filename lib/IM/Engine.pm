package IM::Engine;
use 5.008001;
use Moose;
use MooseX::StrictConstructor;

use IM::Engine::Interface;

our $VERSION = '0.04';

with 'IM::Engine::HasPlugins';

has interface_args => (
    is       => 'ro',
    isa      => 'HashRef',
    init_arg => 'interface',
    required => 1,
);

has interface => (
    is       => 'ro',
    isa      => 'IM::Engine::Interface',
    handles  => ['run'],
    init_arg => undef,
    builder  => '_build_interface',
    lazy     => 1,
);

sub _build_interface {
    my $self = shift;

    my $interface = $self->interface_args
        or confess "You must provide 'interface' to " . blessed($self) . "->new";

    my $protocol = delete $interface->{protocol}
        or confess "Your IM::Engine::Interface definition must include the 'protocol' key";

    if ($protocol !~ s{^\+}{}) {
        $protocol = join '::', 'IM', 'Engine', 'Interface', $protocol;
    }

    Class::MOP::load_class($protocol);

    return $protocol->new(
        %$interface,
        engine => $self,
    );
}

sub engine { shift }

__PACKAGE__->meta->make_immutable;
no Moose;

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

                my $message = $incoming->plaintext;
                $message =~ tr[a-zA-Z][n-za-mN-ZA-M];

                return $incoming->reply($message);
            },
        },
    )->run;

=head1 DESCRIPTION

IM::Engine abstracts away the details of talking through different IM services.
A Jabber bot will be essentially the same as an AIM bot, so IM::Engine
facilitates switching between these different services.

It is currently alpha quality with serious features missing and is rife with
horrible bugs. I'm releasing it under the "release early, release often"
doctrine. Backwards compatibility may be broken in subsequent releases.

In particular, I am likely to move L<IM::Engine::Interface::AIM>,
L<IM::Engine::Interface::Jabber>, and L<IM::Engine::Interface::IRC> into their
own distributions, since they have their own dependencies.

=head1 PROTOCOLS

IM::Engine currently understands the following protocols:

=head2 L<AIM|IM::Engine::Interface::AIM>

Talks AIM using L<Net::OSCAR>:

    IM::Engine->new(
        interface => {
            protocol => 'AIM',
            credentials => {
                screenname => 'foo',
                password   => '...',
            },
        },
        # ...
    );

=head2 L<Jabber|IM::Engine::Interface::Jabber>

Talks XMPP using L<AnyEvent::XMPP>:

    IM::Engine->new(
        interface => {
            protocol => 'Jabber',
            credentials => {
                jid      => 'foo@gchat.com',
                password => '...',
            },
        },
        # ...
    );

=head2 L<IRC|IM::Engine::Interface::IRC>

Talks IRC using L<Bot::BasicBot> (though should switch to L<AnyEvent::IRC>):

    IM::Engine->new(
        interface => {
            protocol => 'IRC',
            credentials => {
                server   => "irc.perl.org",
                port     => 6667,
                channels => ["#moose", "#im-engine"],
                nick     => "Boot",
            },
        },
        # ...
    );

There has been some concern about whether IRC is actually an IM protocol. I
certainly consider private messages to be IM-ish. For some bots, joining
regular human-infested channels would also make sense. Bots that just respond
to chatters (which is most, if not all, of what purl does) make sense outside
of the context of IRC, so that is the use case I am targetting.

=head2 L<REPL|IM::Engine::Interface::REPL>

Opens up a shell where every line of input is an IM. Responses will be printed
to standard output. Handy for testing.

    IM::Engine->new(
        interface => {
            protocol => 'REPL',
        },
        # ...
    );

=head2 L<CLI|IM::Engine::Interface::CLI>

Pass your IM as command-line arguments. Your response will be printed to
standard output. Handy for testing but could also be distributed as a useful
script (I want this for Hiveminder's IM interface C<:)>)

    IM::Engine->new(
        interface => {
            protocol => 'CLI',
        },
        # ...
    );

=head1 AUTHOR

Shawn M Moore, C<sartak@gmail.com>

=head1 SEE ALSO

=over 4

=item L<HTTP::Engine>

The inspiration for the initial design

=item L<IM::Engine::Plugin::Dispatcher>

Uses L<Path::Dispatcher> to provide sugary IM dispatch

=item L<IM::Engine::Plugin::State>

Provides state management methods on L<IM::Engine::User>s

=item L<IM::Engine::Plugin::MultiCommand>

Allows multiple commands to be run in one IM (builds on
L<IM::Engine::Plugin::Dispatcher>)

=head1 COPYRIGHT AND LICENSE

Copyright 2009 Shawn M Moore.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

