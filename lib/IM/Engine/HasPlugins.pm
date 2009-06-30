package IM::Engine::HasPlugins;
use Moose::Role;
use Moose::Util::TypeConstraints;

use IM::Engine::Plugin;

requires 'engine';

sub BUILD { } # provide an empty BUILD if the class lacks one
after BUILD => sub {
    my $self = shift;
    my $args = shift;

    if (my $plugins = delete $args->{plugins}) {
        my @args = @$plugins;
        my @plugins;
        while (my ($class, $args) = splice @args, 0, 2) {
            $class = "IM::Engine::Plugin::$class"
                unless $class =~ s/^\+//;

            Class::MOP::load_class($class);

            push @plugins, $class->new(%$args, engine => $self->engine);
        }
        $self->_set_plugins(\@plugins);
    }
};

has _plugins => (
    metaclass => 'Collection::List',
    isa       => 'ArrayRef[IM::Engine::Plugin]',
    default   => sub { [] },
    provides  => {
        elements => 'plugins',
        grep     => 'find_plugins',
    },

    # Required for passing in engine
    writer    => '_set_plugins',
    init_arg  => undef,
);

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

1;

