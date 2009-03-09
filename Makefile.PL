use inc::Module::Install;
name 'XRDS-Simple';
all_from 'lib/XRDS/Simple.pm';
requires 'Moose', 0.72;
requires 'WWW::Blog::Metadata', 0.02;
requires 'WWW::Blog::Metadata::Yadis', 0.03;
requires 'URI::Fetch', 0.08;
requires 'XML::LibXML', 1.60;

build_requires 'Test::More';
use_test_base;
auto_include_deps;
author_tests('xt');
WriteAll;
