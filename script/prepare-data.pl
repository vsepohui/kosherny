#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw($Bin);
use lib $Bin . '/../lib/';
use 5.022;
use Kosherny::Config;
use JSON;
use utf8;
use Encode;
use Data::Dumper;

sub _slurp_file {
	my $file = shift;

	my $s;
	my $fi;
	open $fi, '<:encoding(utf8)', $file or return;
	$s = join '', <$fi>;
	close $fi;
	
	return $s;
}

my $data  = _slurp_file($Bin. '/vk.dump');
$data .= _slurp_file($Bin. '/t-me.dump');

my @stream; 

for my $s (split /\n/, $data) {
	push @stream, decode_json  Encode::encode_utf8($s);
}

@stream = sort {$b->[1] <=> $a->[1]} @stream;

for my $s (@stream) {
	if ($s) {
		eval {
			say encode_json($s);
		};
		if ($@) {
			warn $@;
		#	die Dumper \$s;
		}
	}
}
	


1;
