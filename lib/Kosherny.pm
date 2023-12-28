package Kosherny;

use strict;
use warnings;
use 5.022;

use Kosherny::Config;

use base 'Mojolicious';

sub startup {
	my $self = shift;
	

	my $config = $self->{config} = new Kosherny::Config;
	
	$self->secrets($config->{secrets});

	my $r = $self->routes;
	$r->get('/')->to('Stream#stream');
	$r->get('/cohen')->to('Stream#cohen');
	$r->get('/donate')->to('Stream#donate');
	$r->get('/links')->to('Stream#links');
}

1;
