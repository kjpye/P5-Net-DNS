# $Id: 32-NSEC3-typelist.t 1389 2015-09-09 13:09:43Z willem $	-*-perl-*-
#

use strict;
use Test::More;
use Net::DNS;
use Net::DNS::Parameters;
use Net::DNS::Text;

my @prerequisite = qw(
		Net::DNS::RR::NSEC3;
		);

foreach my $package (@prerequisite) {
	next if eval "require $package";
	plan skip_all => "$package not installed";
	exit;
}

plan tests => 79;


my $rr = new Net::DNS::RR(
	type	 => 'NSEC3',
	hnxtname => 'irrelevant',
	);

foreach my $rrtype ( 0, 256, 512, 768, 1024 ) {
	my $type = typebyval($rrtype);
	$rr->typelist($type);
	my $rdata = $rr->rdata;
	my ( $text, $offset ) = decode Net::DNS::Text( \$rdata, 4 );
	( $text, $offset ) = decode Net::DNS::Text( \$rdata, $offset );
	my ( $w, $l, $bitmap ) = unpack "\@$offset CCa*", $rdata;
	is( $w, $rrtype >> 8, "expected window number for $type" );
}

foreach my $rrtype ( 0, 7, 8, 15, 16, 23, 24, 31, 32, 39 ) {
	my $type = typebyval($rrtype);
	$rr->typelist($type);
	my $rdata = $rr->rdata;
	my ( $text, $offset ) = decode Net::DNS::Text( \$rdata, 4 );
	( $text, $offset ) = decode Net::DNS::Text( \$rdata, $offset );
	my ( $w, $l, $bitmap ) = unpack "\@$offset CCa*", $rdata;
	is( $l, 1 + ( $rrtype >> 3 ), "expected map length for $type" );
}

foreach my $rrtype ( 0 .. 40, 42 .. 64 ) {
	my $type = typebyval($rrtype);
	$rr->typelist($type);
	my $rdata = $rr->rdata;
	my ( $text, $offset ) = decode Net::DNS::Text( \$rdata, 4 );
	( $text, $offset ) = decode Net::DNS::Text( \$rdata, $offset );
	my ( $w, $l, $bitmap ) = unpack "\@$offset CCa*", $rdata;
	my $last = unpack 'C', reverse $bitmap;
	is( $last, ( 0x80 >> ( $rrtype % 8 ) ), "expected map bit for $type" );
}


exit;

__END__


