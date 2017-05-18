#!/usr/bin/perl

use Modern::Perl '2015';
use autodie;

use FindBin;
use lib $FindBin::RealBin;

use Carp qw(:DEFAULT verbose);
use DPNK::DPNK;
use DPNK::Strava;

sub usage {
	say "Usage: dpnk_upload.pl <date> <from|to> <file.gpx|https://www.strava.com/activities/NNNNN>";
	exit 0;
}

my $date = shift // usage;
my $direction = shift // usage;
my $file = shift // usage;

die 'date must be YYYY-MM-DD' unless $date =~ /^\d\d\d\d-\d\d-\d\d$/;
die 'direction must be from|to' unless $direction =~ /^(from|to)$/;

if (-e $file) {
	$file = [ $file ];
} elsif ($file =~ m|https://www\.strava\.com/activities/(\d+)|) {
	my $filename = $1 . ".gpx";
	$file = [ undef, $filename, Content_Type => 'application/gpx+xml',
		Content => DPNK::Strava->new->retrieve_gpx($file) ];
} else {
	die 'file does not exist or invalid URI supplied';
}

my $dpnk = DPNK::DPNK->new;
$dpnk->login_netrc();
$dpnk->upload_gpx(direction => 'trip_' . $direction, trip_date => $date, file => $file);
