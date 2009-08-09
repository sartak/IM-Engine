package IM::Engine::PluggableConstructor;
use MooseX::Role::Parameterized;
with 'MooseX::Traits';

parameter does_role => (
    does     => 'IM::Engine::ExtendsObject',
    required => 1,
);

role {
    my $p = shift;

    method new_with_plugins => sub {
        my $class = shift;
        my %args  = %{ $class->BUILDARGS(@_) };

        my $engine = delete $args{engine}
            or confess "You must pass the engine to new_with_plugins";

        %args = (
            $engine->plugin_collect(
                role   => $p->does_role,
                method => 'constructor_arguments',
            ),
            %args,
        );

        push @{ $args{traits} || [] }, $engine->plugin_collect(
            role   => $p->does_role,
            method => 'traits',
        );

        $class->new_with_traits(\%args);
    };
};

1;

