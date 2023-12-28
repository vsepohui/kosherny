package Kosherny::Controller::Stream;

use strict;
use warnings;
use 5.022;
use utf8;
use Encode;

use base 'Mojolicious::Controller';

use JSON;
use FindBin qw($Bin);

use constant ITEM_PER_PAGE => 20;


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
	
	my $page = $self->param('page') // 1;
	return $self->reply->not_found if ($page =~ /\D/ || $page < 1);	
	
	my $f = $self->load_file($Bin . '/data.dump');
	my @f = split /\n/, $f;

	my $ipp = $self->ITEM_PER_PAGE();
	my $pages = int (scalar (@f) / $ipp) + 1;
	
	return $self->reply->not_found if $page > $pages;
	@f = splice(@f, ($page - 1) * $ipp, $ipp);


	my @stream;
	for my $s (@f) {
		push @stream, decode_json Encode::encode_utf8($s);
	}


	$self->render(
		stream => \@stream,
		pages  => $pages,
		page   => $page,
	);
}

1;
