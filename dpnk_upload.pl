#!/usr/bin/perl

use Modern::Perl '2015';

use Carp qw(:DEFAULT verbose);
use Data::Printer;
use JSON::XS;
use LWP::UserAgent;
use Net::Netrc;

my $ua = LWP::UserAgent->new;

sub dpnk_login_netrc {
	my $dpnk = Net::Netrc->lookup('dpnk.dopracenakole.cz');
	dpnk_login(username => $dpnk->login, password => $dpnk->password);
}

sub dpnk_login {
	my %params = @_;

	for (qw(username password)) {
		croak "$_ param missing" unless exists $params{$_};
	}

	my $token_query =
		[ grant_type => 'password'
		, client_id => 'u70v0Gum458oywDzjS998L51hgNIQ7P0l4TQMDEX'
		, client_secret => 'Or5DSSXtedN1XYOgJWbWvXrtNapELPcY5sBlACdaBfauKy9UBXrglPuIeZEgnMcbI30QxpRtUpnVBrTEJJoh4CIn2qEJ8ANlhLaklNb1qIb4bfvZ8KVZwbGMjdYbSplf'
		, username => $params{username}
		, password => $params{password}
		];
	my $r = $ua->post('https://dpnk.dopracenakole.cz/oauth2/token/', $token_query);
	croak $r->status_line unless $r->is_success;
	my $tok = decode_json($r->decoded_content);
	croak (q(couldn't obtain token: ) . encode_json($tok)) unless length $tok->{access_token};

	$tok;
}

sub dpnk_upload_gpx {
	my ($tok, %params) = @_;

	for (qw(direction trip_date file)) {
		croak "$_ param missing" unless exists $params{$_};
	}

	my $gpx_content =
		[ direction => $params{direction}
		, trip_date => $params{trip_date}
		, file => [ $params{file} ]
		];
	my $r = $ua->post('https://dpnk.dopracenakole.cz/rest/gpx/',
		Authorization => "Bearer $tok->{access_token}",
		Content_Type => 'form-data', Content => $gpx_content);
	croak $r->status_line unless $r->is_success;

	undef;
}

sub usage {
	say "Usage: dpnk_upload.pl <date> <from|to> <file.gpx>";
	exit 0;
}

my $date = shift // usage;
my $direction = shift // usage;
my $file = shift // usage;

die 'date must be YYYY-MM-DD' unless $date =~ /^\d\d\d\d-\d\d-\d\d$/;
die 'direction must be from|to' unless $direction =~ /^(from|to)$/;
die 'file does not exist' unless -e $file;

my $tok = dpnk_login_netrc();
dpnk_upload_gpx($tok, direction => 'trip_' . $direction, trip_date => $date, file => $file);