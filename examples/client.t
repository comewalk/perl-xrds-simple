#!/usr/bin/perl

use strict;
use warnings;

use XRDS::Simple;
use Data::Dumper;

my $client = XRDS::Simple->new;
my $obj = $client->process('http://useid.org/xrds/xrds.cgi')
    or warn XRDS::Simple->errstr;
warn Dumper $obj;

__END__
