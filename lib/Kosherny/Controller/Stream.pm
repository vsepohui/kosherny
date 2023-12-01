package Kosherny::Controller::Stream;

use strict;
use warnings;

use base 'Mojolicious::Controller';

sub welcome {
	my $self = shift;
	$self->render;
}

1;
