#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Mojolicious::Plugin::JsonToXml' ) || print "Bail out!
";
}

diag( "Testing Mojolicious::Plugin::JsonToXml $Mojolicious::Plugin::JsonToXml::VERSION, Perl $], $^X" );
