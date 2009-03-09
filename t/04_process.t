use strict;
use Test::More tests => 4;

use XRDS::Simple;

my $client = XRDS::Simple->new;
my $obj = $client->process('http://useid.org/xrds/index.cgi');

is($obj->{'xmlns'}, 'xri://$xrds');
is($obj->{'XRD'}->{'Type'}, 'xri://$xrds*simple');
is(@{$obj->{'XRD'}->{'Service'}}[0]->{'URI'}->{'simple:httpMethod'}, 'GET');
is(@{@{$obj->{'XRD'}->{'Service'}}[1]->{'URI'}}[1]->{'content'}, 'http://dvds.example.org/lists/wishes');

__END__
