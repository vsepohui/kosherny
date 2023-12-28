#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw($Bin);
use lib $Bin . '/../lib/';
use 5.022;
use utf8;
use Kosherny::Config;
use JSON::XS;
use Date::Parse;
use Encode;


use Data::Dumper;

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
	for (1..$last_id) {
		my $u = $url . '/' . $_;
		warn $u;
		my $html = fetch($u . '?embed=1&mode=tme');

		next if $html =~ /VIEW IN TELEGRAM/i;
		#die $html;
		#die $u;
		$html =~ /\<div class=\"tgme_widget_message_text js-message_text\" dir=\"auto\"\>(.+?)\<\/div\>/;
		my $text = $1;
		my $image = '';
		if ($html =~ /background-image:url\(\'([^\>]+)\'/) {
			$image = $1;
		}
		$html =~ /\<time datetime=\"([^\"]+)\"/;
		my $date = $1;
		say JSON::XS->new->utf8->encode([$u, str2time($date), Encode::decode_utf8($text), $image]);
	}
	
}



1;
