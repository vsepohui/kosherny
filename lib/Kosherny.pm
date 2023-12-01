package Kosherny;

use strict;
use warnings;

use base 'Mojolicious';

sub startup {
	my $self = shift;

	my $config = $self->plugin('Config');

	$self->secrets($config->{secrets});

	my $r = $self->routes;
	$r->get('/')->to('Example#welcome');
}

1;
