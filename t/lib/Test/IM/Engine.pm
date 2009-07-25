package Test::IM::Engine;
use strict;
use warnings;
use IM::Engine;
use base 'Test::More';

sub import_extra {
    Test::More->export_to_level(2);
    strict->import;
    warnings->import;

    my $caller = caller(1);
    my $engine = IM::Engine->new(
        interface => {
            protocol => 'Test',
            incoming_callback => sub { goto $caller->can('incoming_callback') },
        },
    );

    my $sender = IM::Engine::User->new(
        name => 'tester',
    );

    no strict 'refs';
    *{$caller.'::engine'}     = sub { $engine };
    *{$caller.'::sender'}     = sub { $sender };
    *{$caller.'::htmlish'}    = \&htmlish;
    *{$caller.'::respond_ok'} = \&respond_ok;
}

sub respond_ok {
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my $incoming = shift;
    my $expected = shift;
    my $name     = shift;

    my $caller = caller($Test::Builder::Level - 2);
    my $engine = $caller->engine;
    my $sender = $caller->sender;

    $engine->interface->received_message(
        ref($incoming) ? $incoming : IM::Engine::Incoming->new(
            sender  => $sender,
            message => $incoming,
        ),
    );

    my @expected = ref($expected) eq 'ARRAY' ? @$expected : ($expected);
    my @got = map { $_->message } $engine->interface->splice_outgoing;
    Test::More::is_deeply(\@expected, \@got);
}

sub htmlish {
    unshift @_, 'message' if @_ == 1;
    my %args = (
        traits  => ['HTMLish'],
        sender  => caller->sender,
        @_,
    );

    return IM::Engine::Incoming->new_with_traits(%args);
}

1;

