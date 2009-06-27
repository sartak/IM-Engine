package IM::Engine::HasPlugins;
use Moose::Role;
use Moose::Util::TypeConstraints;

use IM::Engine::Plugin;

requires 'engine';

# Instead of...
# plugins => [
#   IM::Engine::Plugin::Foo->new,
#   IM::Engine::Plugin::Bar->new(baz => 1, quux => 4),
# ],
# ... allow ...
# plugins => [
#   Foo => {},
#   Bar => { baz => 1, quux => 4 },
# ],

subtype 'IM::Engine::Plugins'
     => as 'ArrayRef[IM::Engine::Plugin]';

coerce 'IM::Engine::Plugins'
    => from 'ArrayRef[Str|HashRef]'
    => via {
        my @args = @$_;
        my @plugins;
        while (my ($class, $args) = splice @args, 0, 2) {
            $class = "IM::Engine::Plugin::$class"
                unless $class =~ s/^\+//;
            push @plugins, $class->new($args);
        }
        return \@plugins;
    };

has _plugins => (
    metaclass => 'Collection::List',
    isa       => 'IM::Engine::Plugins',
    init_arg  => 'plugins',
    provides  => {
        elements => 'plugins',
        grep     => 'find_plugins',
    },
);

# XXX: This sucks! plugins don't have access to engine until after they are
# constructed.
sub BUILD {
    my $self = shift;
    for my $plugin ($self->plugins) {
        $plugin->_set_engine($self->engine);
    }
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
        $baton = $plugin->$method($baton);
    }

    return $baton;
}

1;

