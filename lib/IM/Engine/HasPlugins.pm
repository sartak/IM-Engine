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

    # Let them validate that other plugins exist, etc.
    $_->post_initialization for $self->plugins;
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

sub each_plugin {
    my $self = shift;
    my %args = @_;

    my $role     = $args{role};
    my $callback = $args{callback};

    for my $plugin ($self->plugins_with($role)) {
        $callback->($plugin);
    }

    return;
}

sub plugin_relay {
    my $self = shift;
    my %args = @_;

    my $method = $args{method};
    my $baton  = $args{baton};

    $self->each_plugin(
        %args,
        callback => sub { $baton = shift->$method($baton, \%args) },
    );

    return $baton;
}

sub plugin_default {
    my $self = shift;
    my %args = @_;

    my $method = $args{method};
    my $default;

    # I think I want to use Continuation::Escape here :)
    $self->each_plugin(
        %args,
        callback => sub {
            return if $default;

            my $plugin = shift;
            $default = $plugin->$method(\%args);
        },
    );

    return $default;
}

sub plugin_collect {
    my $self = shift;
    my %args = @_;

    my $method = $args{method};
    my @items  = @{ $args{items} || [] };

    $self->each_plugin(
        %args,
        callback => sub { push @items, shift->$method(\%args) },
    );

    return @items;
}

no Moose::Role;

1;

__END__

=head1 NAME

IM::Engine::HasPlugins - role for objects that have plugins

=head1 DESCRIPTION

This should probably only be applied to L<IM::Engine> objects. Beware!

=head1 ATTRIBUTES

=head2 plugins

=head1 METHODS

=head2 find_plugins

Return the L<IM::Engine::Plugin> objects that return true for the passed
coderef.

=head2 plugins_with

Return the L<IM::Engine::Plugin> objects that do the particular role. For
convenience, the role specifier has C<IM::Engine::Plugin::> prepended to it,
unless it is prefixed with C<+>.

=head2 each_plugin

For each plugin that does the C<role> argument, invoke the C<callback>
argument. Returns nothing.

=head2 plugin_relay

For each plugin that does the C<role> argument, call the C<method> on it,
passing the C<baton> argument to it. The return value of C<method> is used as
the baton for the next plugin. The return value of this method is the final
state of the baton.

This is useful for letting each plugin get a chance at modifying some value or
object.

=head2 plugin_default

For each plugin that does the C<role> argument, call the C<method> on it. The
first return value of C<method> that is defined will be returned from this
method.

This is useful for (among other things) letting each plugin get a chance at
short-circuiting some other calculation.

=head2 plugin_collect

For each plugin that does the C<role> argument, call the C<method> on it. The
return values of all C<method> calls are collected into a list to be returned
by this method.

This is useful for (among other things) letting each plugin contribute to
constructor arguments.

=cut

