package IM::Engine::Incoming::IRC::Privmsg;
use Moose;
use MooseX::StrictConstructor;

extends 'IM::Engine::Incoming';

use IM::Engine::Outgoing::IRC::Privmsg;
use constant _reply_class => 'IM::Engine::Outgoing::IRC::Privmsg';

__PACKAGE__->meta->make_immutable;
no Moose;

1;

