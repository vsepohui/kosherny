#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw($Bin);
use lib $Bin . '/../lib/';
use 5.022;
use Kosherny::Config;
use JSON;

my $config = new Kosherny::Config;
my $token = $config->{vk_token};

sub fetch {
	my %params = @_;
	my $url = "https://api.vk.com/method/wall.get?".join '&', map {$_ . '=' . $params{$_}} sort keys %params;
	my $json = `curl -s "$url"`;
	return decode_json $json;
}

for my $feed (@{$config->{vk_feeds}}) {
	my $feed2 = $feed;
	$feed =~ s/^https\:\/\/vk\.com\/(.+)$/$1/;
	
	my $offset = 0;
	
	my $d = fetch(
		domain       => $feed,
		count        => 100,
		offset       => $offset,
		access_token => $token,
		v            => '5.81',
	);
	
	for (@{$d->{response}->{items}}) {
		say encode_json ([$feed2, $_->{date}, $_->{text}]);
	}
	
	if ($d->{response}->{count} > 100) {
		while ($offset + 100 < $d->{response}->{count}) {
			$offset += 100;
			my $d = fetch(
				domain       => $feed,
				count        => 100,
				offset       => $offset,
				access_token => $token,
				v            => '5.81',
			);


			for (@{$d->{response}->{items}}) {
				say encode_json ([$feed2, $_->{date}, $_->{text}]);
			}
			
		}
			
	}
}

1;
