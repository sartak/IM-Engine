package IM::Engine::PluggableConstructor;
use MooseX::Role::Parameterized;
with 'MooseX::Traits';

parameter role_specifier => (
    isa      => 'Str',
    required => 1,
);

role {
    my $p = shift;
    my $role_specifier = $p->role_specifier;

    method new_with_plugins => sub {
        my $class = shift;
        my %args  = %{ $class->BUILDARGS(@_) };

        my $engine = delete $args{engine}
            or confess "You must pass the engine to new_with_plugins";

        %args = (
            $engine->plugin_collect(
                role   => $role_specifier,
                method => 'constructor_arguments',
            ),
            %args,
        );

        push @{ $args{traits} ||= [] }, $engine->plugin_collect(
            role   => $role_specifier,
            method => 'traits',
        );

        $class->new_with_traits(\%args);
    };
};

no MooseX::Role::Parameterized;

1;

__END__

=head1 NAME

IM::Engine::PluggableConstructor - provide C<new_with_plugins>

=head1 DESCRIPTION

Some plugins need to extend built-in classes. For example,
L<IM::Engine::Plugin::State> needs to extend L<IM::Engine::User> with methods
such as C<get_state> and C<set_state>. This role provides a new constructor
C<new_with_plugins> to classes that need to be extensible. Plugins can then
specify roles to use for the instance, as well as additional constructor
parameters.

=head1 PARAMETERS

=head2 role_specifier

A string representing the role that can extend the consuming class. The role
specifier uses the same rules as L<MooseX::Traits>: prefix a C<+> character to
specify an absolute role name, otherwise the class's C<_trait_namespace> is
prepended.

=head1 METHODS

=head2 new_with_plugins

An alternate constructor that includes additional parameters specified by
plugins. This also extends the C<traits> option to include additional traits
specified by plugins.

You must pass the C<engine> argument so we can ask plugins about what to
include.

=cut

