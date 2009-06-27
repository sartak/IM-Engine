package IM::Engine::HasPlugins;
use Moose::Role;

has _plugins => (
    metaclass => 'Collection::List',
    isa       => 'ArrayRef',
    init_arg  => 'plugins',
    provides  => {
        elements => 'plugins',
        grep     => 'find_plugins',
    },
);

sub plugins_with {
    my $self = shift;
    my $role = shift;

    $role = "IM::Engine::Plugin::$role"
        unless $role =~ s/^\+//;

    return $self->find_plugins(sub { $_->does($role) });
}

sub baton_plugins {
    my $self = shift;
    my %args = @_;

    my $role   = $args{role};
    my $method = $args{method};
    my $baton  = $args{baton};

    for my $plugin ($self->plugins_with($role)) {
        $baton = $plugin->$method($baton);
    }

    return $baton;
}

1;

