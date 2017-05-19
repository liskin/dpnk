#!/usr/bin/perl -CSA

use Modern::Perl '2015';
use autodie;

use FindBin;
use lib $FindBin::RealBin;
chdir $FindBin::RealBin;

use Carp qw(:DEFAULT verbose);
use DPNK::DPNK;
use DPNK::Strava;
use File::Touch;

my $strava = DPNK::Strava->new;
my $dpnk = DPNK::DPNK->new;
$dpnk->login_netrc();

for my $commute ($strava->activities_commutes) {
	my ($direction) = ($commute->{name} =~ /(?<!\S)#dpnk_(from|to)\b/);
	next unless $direction;

	my ($date) = ($commute->{start_time} =~ /^(\d\d\d\d-\d\d-\d\d)T/);
	next unless $date;

	my ($id) = ($commute->{id} =~ /^(\d+)$/);
	next unless $id;

	say "$date - $direction: $commute->{name} ($commute->{activity_url})";

	my $uploaded = "./uploaded/" . $id . ".activity";
	if (-e $uploaded) {
		say " already uploaded, skipping";
		next;
	}

	my $gpx = DPNK::Strava->new->retrieve_gpx($commute->{activity_url});
	my $filename = $id . ".gpx";
	my $file = [ undef, $filename, Content_Type => 'application/gpx+xml', Content => $gpx ];
	$dpnk->upload_gpx(direction => 'trip_' . $direction, trip_date => $date, file => $file);
	touch("./uploaded/" . $id . ".activity");
	say " uploaded";
}
