package IM::Engine::RequiresPlugins;
use MooseX::Role::Parameterized;

parameter plugins => (
    is       => 'ro',
    isa      => 'ArrayRef|Str',
    required => 1,
);

role {
    my $p = shift;
    my $plugins = $p->plugins;
    my @plugins = ref($plugins) ? @$plugins : $plugins;

    requires 'post_initialization', 'engine';

    after post_initialization => sub {
        my $self = shift;
        my %has_plugin = map { blessed($_) => 1 } $self->engine->plugins;

        for (@plugins) {
            $has_plugin{$_} or die blessed($self) . " requires the $_ plugin.";
        }
    };
};

no MooseX::Role::Parameterized;

1;

