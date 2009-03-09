use strict;
use Test::More tests => 4;

use XRDS::Simple;

open my $fh, '<', 't/examples/xrds.xml';
my @xml = <$fh>;
close $fh;
my $xml = join '', @xml;

my $client = XRDS::Simple->new;
my $obj = $client->parse($xml);

is($obj->{'xmlns'}, 'xri://$xrds');
is($obj->{'XRD'}->{'Type'}, 'xri://$xrds*simple');
is(@{$obj->{'XRD'}->{'Service'}}[0]->{'URI'}->{'simple:httpMethod'}, 'GET');
is(@{@{$obj->{'XRD'}->{'Service'}}[1]->{'URI'}}[1]->{'content'}, 'http://dvds.example.org/lists/wishes');

__END__
