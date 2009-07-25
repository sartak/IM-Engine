#!/usr/bin/env perl
use lib 't/lib';
use Test::IM::Engine tests => 1;

sub incoming_callback { shift->reply('pong!') }

respond_ok('ping!' => 'pong!');

