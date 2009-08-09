package IM::Engine::PluggableConstructor;
use MooseX::Role::Parameterized;
with 'MooseX::Traits';

parameter role_specifier => (
    does     => 'Str',
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

1;

