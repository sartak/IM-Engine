package IM::Engine::HasPlugins;
use Moose::Role;
use MooseX::AttributeHelpers;

use IM::Engine::Plugin;

use Data::OptList 'mkopt';

requires 'engine';

has plugins_args => (
    is       => 'ro',
    isa      => 'ArrayRef',
    init_arg => 'plugins',
    default  => sub { [] },
);

has _plugins => (
    metaclass => 'Collection::List',
    isa       => 'ArrayRef[IM::Engine::Plugin]',
    builder   => '_build_plugins',
    init_arg  => undef,
    lazy      => 1,
    provides  => {
        elements => 'plugins',
        grep     => 'find_plugins',
    },
);

sub BUILD { } # provide an empty default in case the class has none
after BUILD => sub {
    my $self = shift;

    # Initialize plugin list so the plugins can perform further initialization
    $self->plugins;
};

sub _build_plugins {
    my $self = shift;

    my $args = mkopt(
        $self->plugins_args,
        'plugins',
        0, # can have more than one instance of the same plugin
        [qw(HASH)],
    );

    my @plugins;
    for (@$args) {
        my ($class, $params) = @$_;
        $class = "IM::Engine::Plugin::$class"
            unless $class =~ s/^\+//;

        Class::MOP::load_class($class);

        push @plugins, $class->new(
            %{ $params || {} },
            engine => $self->engine,
        );
    }
    return \@plugins;
}

sub plugins_with {
    my $self = shift;
    my $role = shift;

    $role = "IM::Engine::Plugin::$role"
        unless $role =~ s/^\+//;

    return $self->find_plugins(sub { $_->does($role) });
}

sub plugin_relay {
    my $self = shift;
    my %args = @_;

    my $role   = $args{role};
    my $method = $args{method};
    my $baton  = $args{baton};

    for my $plugin ($self->plugins_with($role)) {
        $baton = $plugin->$method($baton, \%args);
    }

    return $baton;
}

sub plugin_default {
    my $self = shift;
    my %args = @_;

    my $role   = $args{role};
    my $method = $args{method};

    for my $plugin ($self->plugins_with($role)) {
        my $default = $plugin->$method(\%args);
        return $default if defined $default;
    }

    return;
}

sub each_plugin {
    my $self = shift;
    my %args = @_;

    my $role   = $args{role};
    my $method = $args{method};

    for my $plugin ($self->plugins_with($role)) {
        $plugin->$method(\%args);
    }

    return;
}

1;

