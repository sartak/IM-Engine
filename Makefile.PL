use inc::Module::Install;

name     'IM-Engine';
all_from 'lib/IM/Engine.pm';

requires 'Moose';
requires 'MooseX::AttributeHelpers';

features(
    'AIM interface' => [
        -default => 0,
        recommends('Net::OSCAR'),
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

