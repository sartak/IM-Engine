#!/usr/bin/env perl
use strict;
use warnings;
use IM::Engine;

IM::Engine->new(
    interface => {
        protocol => 'CLI',
        incoming_callback => sub {
            my $incoming = shift;

            my $message = $incoming->plaintext;
            $message =~ tr[a-zA-Z][n-za-mN-ZA-M];

            return $incoming->reply($message);
        },
    },
)->run;

