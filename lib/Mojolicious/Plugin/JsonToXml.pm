package Mojolicious::Plugin::JsonToXml;

use strict;
use warnings;

use base 'Mojolicious::Plugin';

our $VERSION = '0.02';

sub register {
	my ($self, $app, $conf) = @_;
	
	$app->plugins->add_hook(after_static_dispatch => sub {
		my ($self, $c) = @_;
		my $url = $c->req->url;

		if ($url =~ s/\.xml\b/\.json/) {
			$c->req->url( Mojo::URL->new($url) );
			$c->stash(xml => 1);
		}
	});

	$app->plugins->add_hook(after_dispatch => sub {
		my ($self, $c) = @_;
		
		if ($c->stash('xml') && $c->res->code == 200) {
			$c->stash(format => 'xml');
			$c->res->headers->content_type( $app->types->type('xml') );

			$c->res->body( json2xml($c->res->body) );
		}
	});
}

sub json2xml {
	my $json = shift;
	my $conf = shift;
	
	my $data = $json ? Mojo::JSON->new->decode( $json ) : undef;
	my $xml  = qq(<?xml version="1.0" encoding="UTF-8"?>\n); # XXX: charset
	
	unless ($data) {
		$xml .= qq(<empty />\n);
	} else {
		$xml .= _xml( $data => 1 ) . qq(\n);
	}
	
	return $xml;
}

sub _xml {
	my $data = shift;
	my $flag = shift;
	
	my $t = '';
	if (ref $data eq 'HASH') {
		$t .= "<$_>" . _xml($data->{$_}) . "</$_>" for sort keys %$data;
	}
	elsif (ref $data eq 'ARRAY') {
		$t .= '<list>' if $flag;
		$t .= '<item>' ._xml($_) . '</item>' for @$data;
		$t .= '</list>' if $flag;
	}
	else {
		$t .= Mojo::ByteStream->new($data)->xml_escape;
	}
	
	return $t;
}

1;

__END__

=head1 NAME

Mojolicious::Plugin::JsonToXml - JSON to XML Mojolicious Plugin

=head1 SYNOPSIS

	# Mojolicious
	$self->plugin('json_to_xml');
	
	# Mojolicious::Lite
	plugin 'json_to_xml';
	
	get '/test.json' => sub { shift->render_json({ response => 'ok' }) };


Check urls: /test.json, /test.xml

=head1 DESCRIPTION

L<Mojolicous::Plugin::JsonToXml> is a plugin to easily use XML format if exists JSON format.
Automation render JSON data to XML data

=head1 METHODS

L<Mojolicious::Plugin::JsonToXml> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 C<register>

	$plugin->register;

Register plugin hooks in L<Mojolicious> application.

=head2 C<json2xml>

	my $xml = $plugin->json2xml( $json );

Simple render json to xml.

If $json is missing or empty, xml contains root tag <empty />.

Each element of array is <item> ... </item>.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicious.org>.

=head1 AUTHOR

Anatoly Sharifulin <sharifulin@gmail.com>

=head1 BUGS

Please report any bugs or feature requests to C<bug-mojolicious-plugin-jsontoxml at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.htMail?Queue=Mojolicious-Plugin-JsonToXml>.  We will be notified, and then you'll
automatically be notified of progress on your bug as we make changes.

=over 5

=item * Github

L<http://github.com/sharifulin/Mojolicious-Plugin-JsonToXml/tree/master>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.htMail?Dist=Mojolicious-Plugin-JsonToXml>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Mojolicious-Plugin-JsonToXml>

=item * CPANTS: CPAN Testing Service

L<http://cpants.perl.org/dist/overview/Mojolicious-Plugin-JsonToXml>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Mojolicious-Plugin-JsonToXml>

=item * Search CPAN

L<http://search.cpan.org/dist/Mojolicious-Plugin-JsonToXml>

=back

=head1 COPYRIGHT & LICENSE

Copyright (C) 2010 by Anatoly Sharifulin.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
