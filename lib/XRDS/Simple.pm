package XRDS::Simple;

use strict;
use warnings;
use 5.008_001;
our $VERSION = '0.02';

use Moose;

extends 'Class::ErrorHandler';

has 'ua'  => (
    is => 'rw',
    isa => 'LWP::UserAgent',
    default => sub {
       require LWP::UserAgent;
       LWP::UserAgent->new( agent => __PACKAGE__ . "/" . $VERSION );
    }
);

__PACKAGE__->meta->make_immutable;

no Moose;

sub discovery {
    my ($self, $uri) = @_;

    # HEAD protocol section
    my $res = $self->ua->head($uri);
    if (my $xrds_uri = $res->header('x-xrds-location')) {
        return URI->new($xrds_uri); 
    }
    elsif ($res->header('content-type') eq 'application/xrds+xml') {
        return ref($uri) =~ m/^URI/ ? $uri : URI->new($uri);
    }

    # GET protocol section
    require WWW::Blog::Metadata;
    my $meta = WWW::Blog::Metadata->extract_from_uri($uri)
        or return XRDS::Simple->error(WWW::Blog::Metadata->errstr);
    return URI->new($meta->xrds_location)
        if $meta->xrds_location;

    return;
}

sub fetch {
    my ($self, $uri) = @_;

    # Requesting Document
    require URI::Fetch;
    my $res = URI::Fetch->fetch($uri)
        or return XRDS::Simple->error(URI::Fetch->errstr);

    $res->content;
}

sub parse {
    my ($self, $xml) = @_;

    require XML::LibXML;
    my $parser = XML::LibXML->new;
    my $dom = $parser->parse_string($xml);
    my $obj = $self->_parse_to_obj($dom);
    $obj;
}

sub _parse_to_obj {
    my ($self, $dom) = @_;

    my $root = $dom->documentElement;
    my $obj = $self->_make_obj($root);
    my @attributes = $root->attributes;
    for my $attr (@attributes) {
        my $node_name = $attr->nodeName;
        $obj->{$node_name} = $root->getAttribute($node_name);
    }
    $obj;
}

sub _make_obj {
    my ($self, $parent, $parent_obj) = @_;
    my $obj;
    my @children = grep ref($_) =~ /Element/, $parent->childNodes; 
    for my $child (@children) {
        my $child_node_name = $child->nodeName;
        # get attributes
        my $attr_obj;
        my @attributes = $child->attributes;
        for my $attr (@attributes) {
            my $node_name = $attr->nodeName;
            $attr_obj->{$node_name} = $child->getAttribute($node_name);
        }

        # parse child elements (recursive)
        my $child_obj = $self->_make_obj($child);

        # append child object
        if ($obj->{$child_node_name}) {
            unless (ref($obj->{$child_node_name}) eq 'ARRAY') {
                my $tmp = delete $obj->{$child_node_name};
                push @{$obj->{$child_node_name}}, $tmp;
            }
            push @{$obj->{$child_node_name}}, $child_obj;
        } else {
            $obj->{$child_node_name} = $child_obj;
        }

        # Append attributes
        if (ref($obj->{$child_node_name}) eq 'ARRAY') {
            my $index = scalar(@{$obj->{$child_node_name}}) - 1;
            for my $key (keys %$attr_obj) {
                @{$obj->{$child_node_name}}[$index]->{$key} = $attr_obj->{$key};
            }
        } else {
            for my $key (keys %$attr_obj) {
                $obj->{$child_node_name}->{$key} = $attr_obj->{$key};
            }
        }
    }
    unless (@children) {
        if ($parent->hasAttributes()) {
            $obj->{'content'} = $parent->textContent;
        } else { 
            $obj = $parent->textContent;
        }
    }
    $obj;
}

sub process {
    my ($self, $uri) = @_;

    # discovery
    my $xrds_uri = $self->discovery($uri)
        or return XRDS::Simple->error('discovery error:' . (__PACKAGE__->errstr || ''));

    # fetch
    my $xml = $self->fetch($xrds_uri)
        or return XRDS::Simple->error('fetch error:' . (__PACKAGE__->errstr || ''));

    # parse to HASH
    my $obj = $self->parse($xml)
        or return XRDS::Simple->error('parse error:' . (__PACKAGE__->errstr || ''));

    $obj;
}

1;
__END__

=encoding utf-8

=for stopwords

=head1 NAME

XRDS::Simple - discovery, fetch and parse Resource Description Document by using XRDS-Simple

=head1 SYNOPSIS

  use XRDS::Simple;

  my $client = XRDS::Simple->new;

  # discovery
  my $uri = $client->discovery('http://www.example.com/')
      or warn XRDS::Simple->errstr;

  # fetch
  my $xml = $client->fetch($uri)
      or warn XRDS::Simple->errstr;

  # parse to HASH
  my $obj = $client->parse($xml)
      or warn XRDS::Simple->errstr;

  # discovery, fetch, and parse to HASH
  my $obj = $client->process('http://www.example.com/')
      or warn XRDS::Simple->errstr;

=head1 DESCRIPTION

XRDS::Simple is a consumer of XRDS-Simple.

=head1 METHODS

=head2 new

see L<Moose>

=head2 meta

see L<Moose>

=head2 discovery

return URI of Resource Description Document.

=head2 fetch

return content of Resource Description Document. 

=head2 parse

return HASH which Resource Description Document is parsed.

=head2 process

return HASH which Resource Description Document is parsed.
this method run all (discovery, fetch and parse).

=head2 ua

return user agent object.
(Default: L<LWP::UserAgent>)

=head1 AUTHOR

Takatsugu Shigeta E<lt>shigeta@cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

XRDS-Simple 1.0 Draft L<http://xrds-simple.net/core/1.0/>

=cut
