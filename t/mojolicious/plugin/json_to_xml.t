#!/usr/bin/env perl
use lib qw(lib /tk/mojo/lib); # XXX
use Mojolicious::Lite;

plugin 'json_to_xml';

get '/test.json' => sub { shift->render_json({ response => 'ok' }) };

app->log->level('error');

use Test::More tests => 9;
use Test::Mojo;

my $t = Test::Mojo->new;

$t->get_ok('/test.json')
	->status_is(200)
	->json_content_is({ response => 'ok'}, 'json')
;

$t->get_ok('/test.xml')
	->status_is(200)
	->content_is(qq(<?xml version="1.0" encoding="UTF-8"?>\n<response>ok</response>\n), 'xml')
;

#

my $json = Mojo::JSON->new;

sub json2xml { &Mojolicious::Plugin::JsonToXml::json2xml }

is
	json2xml(),
	qq(<?xml version="1.0" encoding="UTF-8"?>\n<empty />\n),
	'xml empty'
;

is
	json2xml( $json->encode([ 1, 2 ]) ),
	qq(<?xml version="1.0" encoding="UTF-8"?>\n<list><item>1</item><item>2</item></list>\n),
	'xml list'
;

is
	json2xml( $json->encode({ root => [ { id => 1, title => 'JSON & XML' }, { id => 2 } ] }) ),
	qq(<?xml version="1.0" encoding="UTF-8"?>\n<root><item><id>1</id><title>JSON &amp; XML</title></item><item><id>2</id></item></root>\n),
	'xml hash, list and escape'
;
