package IM::Engine::HasEngine;
use Moose::Role;

use IM::Engine;

has engine => (
    is       => 'ro',
    isa      => 'IM::Engine',
    weak_ref => 1,
);

no Moose::Role;

1;

