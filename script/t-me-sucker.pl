#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw($Bin);
use lib $Bin . '/../lib/';
use 5.022;
use Kosherny::Config;

my $config = new Kosherny::Config;

sub fetch {
	my $url = shift;
	return `curl -s "$url"`;
}

sub parse_html {
	my $url  = shift;
	my $html = shift;

	my $page;
	while ($html =~ m/href=\"$url\/(\d+)\"/gim) {
		$page = $1;
	}
	
	return $page;
}

for my $url (@{$config->{t_me}}) {
	my $url2 = $url;
	$url2 =~ s/t\.me\//t.me\/s\//;
	my $html = fetch($url2);
	my $last_id = parse_html($url, $html);
	warn $last_id;
	
}

1;
