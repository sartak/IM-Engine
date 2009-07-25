use inc::Module::Install;

name     'IM-Engine';
all_from 'lib/IM/Engine.pm';

requires 'Moose';
requires 'MooseX::AttributeHelpers';
requires 'MooseX::Traits';
requires 'MooseX::StrictConstructor';
requires 'Scalar::Util';

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
        recommends('Bot::BasicBot'),
    ],
);

tests('t/*.t t/*/*.t');

auto_install;
WriteAll;

