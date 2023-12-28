#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw($Bin);
use lib $Bin . '/../lib/';
use 5.022;
use Kosherny::Config;
use JSON;
use Date::Parse;
use AnyEvent;
use AnyEvent::HTTP;

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

my $cv = AnyEvent::condvar;

for my $url (@{$config->{t_me}}) {
	my $url2 = $url;
	$url2 =~ s/t\.me\//t.me\/s\//;
	my $html = fetch($url2);
	my $last_id = parse_html($url, $html);
	for (1..$last_id) {
		my $u = $url . '/' . $_;
		
		http_get $u . '?embed=1&mode=tme', sub {
			warn $u;
			$html = $_[1];
			next if $html =~ /VIEW IN TELEGRAM/i;
			#die $u;
			$html =~ /\<div class=\"tgme_widget_message_text js-message_text\" dir=\"auto\"\>(.+?)\<\/div\>/;
			my $text = $1;
			my $image = '';
			if ($html =~ /background-image:url\(\'([^\>]+)\'/) {
				$image = $1;
			}
			$html =~ /\<time datetime=\"([^\"]+)\"/;
			my $date = $1;
			say encode_json([$u, str2time($date), $text, $image]);
		}
	}
	
}

$cv->recv;

1;
