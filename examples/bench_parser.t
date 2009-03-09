#!/usr/bin/perl

use strict;
use warnings;

use Benchmark;
use IO::File;
use XML::LibXML;
use XML::Simple;
use XRDS::Simple;

my $fh = IO::File->new;
#$fh->open('< t/examples/google.openid.xrds');
#$fh->open('< t/examples/fireeagle.yahoo.xrds');
#$fh->open('< t/examples/opensocial.sample.xrds');
#$fh->open('< t/examples/partuza.xrds');
#$fh->open('< t/examples/yahoo.openid.xrds');
$fh->open('< t/examples/xrds.xml');
my @xml = <$fh>;
$fh->close;
my $content = join '', @xml;

my $xl = XML::LibXML->new;
my $xs = XML::Simple->new;
my $xrds = XRDS::Simple->new;
timethese(1000, {
    'XML::LibXML' => sub {
                         $xl->parse_string($content);
                     },
    'XML::Simple' => sub {
                         $xs->XMLin($content);
                     },
    'XRDS::Simpe' => sub {
                         $xrds->parse($content);
                     },
});

__END__
