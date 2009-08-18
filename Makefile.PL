use inc::Module::Install;

name     'IM-Engine';
all_from 'lib/IM/Engine.pm';
githubmeta;

requires 'Moose';
requires 'MooseX::AttributeHelpers';
requires 'MooseX::Traits';
requires 'MooseX::StrictConstructor';
requires 'MooseX::Role::Parameterized';

requires 'Scalar::Util';
requires 'Data::OptList';

features(
    'AIM interface' => [
        -default => 0,
        recommends('Net::OSCAR'),
        recommends('HTML::TreeBuilder'),
    ],
    'Jabber interface' => [
        -default => 0,
        recommends('AnyEvent::XMPP'),
    ],
    'IRC interface' => [
        -default => 0,
        recommends('AnyEvent::IRC'),
    ],
);

tests('t/*.t t/*/*.t');

auto_install;
WriteAll;

