package DPNK::UA;

use Modern::Perl '2015';
use autodie;

use Carp qw(:DEFAULT verbose);
use LWP::UserAgent;

sub new {
	my ($class, @params) = @_;
	return bless({}, $class);
}

sub ua {
	my ($self) = @_;
	$self->{ua} //= $self->get_ua;
}

sub get_ua {
	my $ua = LWP::UserAgent->new(timeout => 20);
	$ua->cookie_jar({});

	return $ua;
}

1;
