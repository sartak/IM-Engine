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

    no strict 'refs';
    *{$caller.'::engine'} = sub { $engine };
}

1;

