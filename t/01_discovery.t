use strict;
use Test::More tests => 8;

use XRDS::Simple;

my $client = XRDS::Simple->new;

my $txt_uri = 'http://useid.org/xrds/index.cgi';
my $xrds_uri = $client->discovery($txt_uri);
is(ref($xrds_uri), 'URI::http');
is($xrds_uri->as_string, 'http://useid.org/xrds/xrds.xml');

my $uri = URI->new($txt_uri);
$xrds_uri = $client->discovery($uri);
is(ref($xrds_uri), 'URI::http');
is($xrds_uri->as_string, 'http://useid.org/xrds/xrds.xml');

# application/xrds+xml
$uri = URI->new('http://useid.org/xrds/xrds.cgi');
$xrds_uri = $client->discovery($uri);
is(ref($xrds_uri), 'URI::http');
is($xrds_uri->as_string, 'http://useid.org/xrds/xrds.cgi');

# meta tag
$uri = URI->new('http://useid.org/xrds/xrds.html');
$xrds_uri = $client->discovery($uri);
is(ref($xrds_uri), 'URI::http');
is($xrds_uri->as_string, 'http://useid.org/xrds/xrds.xml');
__END__
