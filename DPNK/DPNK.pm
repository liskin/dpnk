package DPNK::DPNK;

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

sub login_netrc {
	my ($self) = @_;

	my $dpnk = Net::Netrc->lookup('dpnk.dopracenakole.cz');
	$self->login(username => $dpnk->login, password => $dpnk->password);
}

sub login {
	my ($self, %params) = @_;

	for (qw(username password)) {
		croak "$_ param missing" unless defined $params{$_};
	}

	my $token_query =
		[ grant_type => 'password'
		, client_id => 'u70v0Gum458oywDzjS998L51hgNIQ7P0l4TQMDEX'
		, client_secret => 'Or5DSSXtedN1XYOgJWbWvXrtNapELPcY5sBlACdaBfauKy9UBXrglPuIeZEgnMcbI30QxpRtUpnVBrTEJJoh4CIn2qEJ8ANlhLaklNb1qIb4bfvZ8KVZwbGMjdYbSplf'
		, username => $params{username}
		, password => $params{password}
		];
	my $r = $self->ua->post('https://dpnk.dopracenakole.cz/oauth2/token/', $token_query);
	croak $r->status_line unless $r->is_success;
	my $tok = decode_json($r->decoded_content);
	croak (q(couldn't obtain token: ) . encode_json($tok)) unless length $tok->{access_token};
	$self->{token} = $tok;

	undef;
}

sub upload_gpx {
	my ($self, %params) = @_;

	for (qw(direction trip_date file)) {
		croak "$_ param missing" unless defined $params{$_};
	}
	croak "not logged in" unless defined $self->{token};

	my $gpx_content =
		[ direction => $params{direction}
		, trip_date => $params{trip_date}
		, file => $params{file}
		];
	my $r = $self->ua->post('https://dpnk.dopracenakole.cz/rest/gpx/',
		Authorization => "Bearer $self->{token}->{access_token}",
		Content_Type => 'form-data', Content => $gpx_content);
	croak $r->status_line unless $r->is_success;

	undef;
}

1;
