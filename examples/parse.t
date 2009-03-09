#!/usr/bin/perl

use strict;
use warnings;

use XRDS::Simple;
use IO::File;
use Data::Dumper;

my $client = XRDS::Simple->new;

my $fh = IO::File->new;
#$fh->open('< t/examples/fireeagle.yahoo.xrds');
#$fh->open('< t/examples/opensocial.sample.xrds');
$fh->open('< t/examples/partuza.xrds');
#$fh->open('< t/examples/google.openid.xrds');
#$fh->open('< t/examples/yahoo.openid.xrds');
my $content;
while (<$fh>) {
    $content .= $_;
}
$fh->close;

warn Dumper $client->parse($content);

__END__
