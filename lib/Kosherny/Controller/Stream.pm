package Kosherny::Controller::Stream;

use strict;
use warnings;
use 5.022;
use utf8;
use Encode;

use base 'Mojolicious::Controller';

use JSON;
use FindBin qw($Bin);


sub _slurp_file {
	my $self = shift;
	my $file = shift;

	my $s;
	my $fi;
	open $fi, '<:encoding(utf8)', $file or return;
	$s = join '', <$fi>;
	close $fi;
	
	return $s;
}


sub load_file {
	my $self = shift;
	my $file = shift;
	
	state $cache = {};
	
	unless (exists $cache->{$file}) {
		$cache->{$file}->{content} = $self->_slurp_file($file);
		$cache->{$file}->{ts} = (stat($file))[9];
	} else {
		if ($cache->{$file}->{ts} != (stat($file))[9]) {
			$cache->{$file}->{content} = $self->_slurp_file($file);
			$cache->{$file}->{ts} = (stat($file))[9];
		}
	}
	
	return $cache->{$file}->{content};
}


sub stream {
	my $self = shift;
	
	my $f = $self->load_file($Bin . '/vk.dump');
	
	my @stream;
	for my $s (split /\n/, $f) {
		push @stream, decode_json  Encode::encode_utf8($s);
	}
	
	@stream = sort {$b->[1] <=> $a->[1]} @stream;
	
	$self->render(stream => \@stream);
}

1;
