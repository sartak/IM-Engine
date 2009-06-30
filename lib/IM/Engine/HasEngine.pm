package IM::Engine::HasEngine;
use Moose::Role;

use IM::Engine;

has engine => (
    is       => 'ro',
    writer   => '_set_engine',
    isa      => 'IM::Engine',
    weak_ref => 1,
);

1;

