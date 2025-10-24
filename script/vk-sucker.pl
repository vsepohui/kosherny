#!/usr/bin/perl

use 5.028;
use strict;
use warnings;
use lib '../lib/';

use Kosherny::Config;
use JSON;

my $config = new Kosherny::Config;
my $token = $config->{vk_token};

sub fetch {
	my %params = @_;
	my $url = "https://api.vk.com/method/wall.get?".join '&', map {$_ . '=' . $params{$_}} sort keys %params;
	my $json = qq[curl -s "$url"];
	$json = `$json`;
	return decode_json $json;
}

my %f = map {$_ =>1} @{$config->{vk_feeds}};

for my $feed (map {"https://vk.com/$_"} keys %f) {
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
				next unless $_->{text};
				say encode_json ([$feed2, $_->{date}, $_->{text}]);
			}
			
		}
			
	}
}

1;
