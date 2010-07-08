#!/usr/bin/env perl
use lib qw(lib /tk/mojo/lib); # XXX
use Mojolicious::Lite;

plugin 'json_to_xml', {
	exclude => [ qr{/no\.xml}, '/no2.xml' ]
};

get '/test.json' => sub { shift->render_json({ response => 'ok' }) };

get '/list.json' => sub { shift->render_json([1, 2, 3]) };

get '/tags.json' => sub { shift->render_json({
	tests => [
		{ id => 1, title => 'JSON & XML', __node => 'test' },
		{ id => 2, title => 'JSON > XML', __node => 'test' },
	]
}) };

get '/error.json' => sub {
	my $self = shift;
	
	$self->res->code(404);
	$self->render_json({ error => 'not found' });
};

get '/no.xml' => { text => qq(<?xml version="1.0" encoding="UTF-8"?>\n<no />) };

get '/no2.xml' => { text => qq(<?xml version="1.0" encoding="UTF-8"?>\n<no2 />) };

app->log->level('error');

use Test::More tests => 28;
use Test::Mojo;

my $t = Test::Mojo->new;

$t->get_ok('/test.json')
	->status_is(200)
	->json_content_is({ response => 'ok'}, 'test json')
;

$t->get_ok('/test.xml')
	->status_is(200)
	->content_is(qq(<?xml version="1.0" encoding="UTF-8"?>\n<response>ok</response>\n), 'test xml')
;

$t->get_ok('/list.xml')
	->status_is(200)
	->content_is(
		qq(<?xml version="1.0" encoding="UTF-8"?>\n) .
		qq(<list><item>1</item><item>2</item><item>3</item></list>\n),
	'list xml')
;

$t->get_ok('/tags.json')
	->status_is(200)
	->json_content_is({
		tests => [
			{ id => 1, title => 'JSON & XML' },
			{ id => 2, title => 'JSON > XML' },
		]
	}, 'tags json')
;

$t->get_ok('/tags.xml')
	->status_is(200)
	->content_is(
		qq(<?xml version="1.0" encoding="UTF-8"?>\n) .
		qq(<tests>) .
		qq(<test><id>1</id><title>JSON &amp; XML</title></test>) .
		qq(<test><id>2</id><title>JSON &gt; XML</title></test>) .
		qq(</tests>\n),
	'tags xml')
;

$t->get_ok('/error.json')
	->status_is(404)
	->json_content_is({ error => 'not found' }, 'error json')
;

$t->get_ok('/error.xml')
	->status_is(404)
	->content_is(qq(<?xml version="1.0" encoding="UTF-8"?>\n<error>not found</error>\n), 'error xml')
;

$t->get_ok('/no.xml')
	->status_is(200)
	->content_is(qq(<?xml version="1.0" encoding="UTF-8"?>\n<no />), 'exclude xml')
;

$t->get_ok('/no2.xml')
	->status_is(200)
	->content_is(qq(<?xml version="1.0" encoding="UTF-8"?>\n<no2 />), 'exclude xml 2')
;

#

my $json = Mojo::JSON->new;

sub json2xml { &Mojolicious::Plugin::JsonToXml::json2xml }

is
	json2xml(),
	qq(<?xml version="1.0" encoding="UTF-8"?>\n<empty />\n),
	'empty xml'
;
