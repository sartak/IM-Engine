package IM::Engine::Message::HTMLish;
use Moose::Role;
use HTML::TreeBuilder;

around _build_plaintext => sub {
    my $orig = shift;
    my $htmlish = $orig->(@_);
    return HTML::TreeBuilder->new_from_content($htmlish)->as_text;
};

no Moose::Role;

1;

