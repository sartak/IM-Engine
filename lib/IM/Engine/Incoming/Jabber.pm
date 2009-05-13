package IM::Engine::Incoming::Jabber;
use Moose;

extends 'IM::Engine::Incoming';

use constant _reply_class => 'IM::Engine::Outgoing::Jabber';


__PACKAGE__->meta->make_immutable;
no Moose;

1;

