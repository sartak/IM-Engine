package IM::Engine::Interface::IRC::Bot;
use strict;
use warnings;
use base 'Bot::BasicBot';

sub said {
    my $self = shift;
    $self->{im_interface}->said(@_);
}

1;

