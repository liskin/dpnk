package DPNK::Strava;

use Modern::Perl '2015';
use autodie;

use parent 'DPNK::UA';

use Carp qw(:DEFAULT verbose);
use JSON::XS;
use LWP::UserAgent;
use Net::Netrc;

sub new {
	my ($class) = @_;
	$class->SUPER::new();
}

sub cookie {
	my ($self) = @_;
	$self->{cookie} //= $self->get_cookie;
}

sub get_cookie {
	my ($self) = @_;

	my $strava = Net::Netrc->lookup('www.strava.com');
	$strava->account // die 'pls put strava _strava3_session into ".netrc" as "account"';
}

sub retrieve_gpx {
	my ($self, $url) = @_;

	my $r = $self->ua->get("$url/export_gpx", Cookie => $self->cookie);
	croak $r->status_line unless $r->is_success;

	$r->decoded_content;
}

sub activities_commutes {
	my ($self) = @_;

	my $r = $self->ua->get("https://www.strava.com/athlete/training_activities?commute=true",
		X_Requested_With => 'XMLHttpRequest',
		Cookie => $self->cookie);
	croak $r->status_line unless $r->is_success;

	@{decode_json($r->decoded_content)->{models}};
}

1;
