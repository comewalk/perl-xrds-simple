use strict;
use Test::More tests => 1;

use XRDS::Simple;

my $client = XRDS::Simple->new;
my $xml = $client->fetch('http://useid.org/xrds/xrds.xml');

open my $fh, '<', 't/examples/xrds.xml';
my @xml = <$fh>;
close $fh;

is($xml, join('', @xml));

__END__
