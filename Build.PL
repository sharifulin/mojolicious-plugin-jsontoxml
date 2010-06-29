use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name         => 'Mojolicious::Plugin::JsonToXml',
	license             => 'perl',
	dist_author         => 'Anatoly Sharifulin <sharifulin@gmail.com>',
	dist_version_from   => 'lib/Mojolicious/Plugin/JsonToXml.pm',
	dist_abstract       => 'JSON to XML Mojolicious Plugin',
	build_requires => {
		'Test::More' => 0,
		'Test::Mojo' => 0,
	},
	requires => {
		'Mojolicious::Plugin' => 0,
	},
	add_to_cleanup  => [],
	meta_merge => {
		resources => {
			repository => 'git://github.com/sharifulin/mojolicious-plugin-jsontoxml.git',
		},
		keywords => ['mojo', 'mojolicious', 'plugin', 'json', 'xml'],
	},
	create_makefile_pl => 'traditional',
);

$builder->create_build_script();
