# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Lemonldap-NG-Manager.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';
package My::Portal;

use strict;
use IO::String;
use Test::More tests => 10;
BEGIN { use_ok('Lemonldap::NG::Common::CGI') }

use base ('Lemonldap::NG::Common::CGI');

sub mySubtest {
    return 'OK1';
}

sub abort {
    shift;
    $, = '';
    print STDERR @_;
    die 'abort has been called';
}

sub quit {
    2;
}

our $param;

sub param {
    return $param;
}

sub soapfunc {
    return 'SoapOK';
}

our $buf;

tie *STDOUT, 'IO::String', $buf;
our $lastpos = 0;

sub diff {
    my $str = $buf;
    $str =~ s/^.{$lastpos}//s if ($lastpos);
    $str =~ s/\r//gs;
    $lastpos = length $buf;
    return $str;
}

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $cgi;

$ENV{SCRIPT_NAME}     = '/test.pl';
$ENV{SCRIPT_FILENAME} = 't/20-Common-CGI.t';
$ENV{REQUEST_METHOD}  = 'GET';
$ENV{REQUEST_URI}     = '/';
$ENV{QUERY_STRING}    = '';

#$cgi = CGI->new;
ok( ( $cgi = Lemonldap::NG::Common::CGI->new() ), 'New CGI' );
bless $cgi, 'My::Portal';

# Test header_public
ok( $buf = $cgi->header_public('t/20-Common-CGI.t'), 'header_public' );
ok( $buf =~ /Cache-control: public; must-revalidate; max-age=\d+\r?\n/s,
    'Cache-Control' );
ok( $buf =~ /Last-modified: /s, 'Last-Modified' );

# Test _sub mechanism
ok( $cgi->_sub('mySubtest') eq 'OK1', '_sub mechanism 1' );
$cgi->{mySubtest} = sub { return 'OK2' };
ok( $cgi->_sub('mySubtest') eq 'OK2', '_sub mechanism 2' );

# SOAP
SKIP: {
    eval { require SOAP::Lite };
    skip "SOAP::Lite is not installed, so CGI SOAP functions will not work", 3
      if ($@);
    $ENV{HTTP_SOAPACTION} =
      'http://localhost/Lemonldap/NG/Common/CGI/SOAPService#soapfunc';
    $param =
'<?xml version="1.0" encoding="UTF-8"?><soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><soapfunc xmlns="http://localhost/Lemonldap/NG/Common/CGI/SOAPService"><var xsi:type="xsd:string">fr</var></soapfunc></soap:Body></soap:Envelope>';
    ok( $cgi->soapTest('soapfunc') == 2, 'SOAP call exit fine' );
    my $tmp = diff();
    ok( $tmp =~ /^Status: 200/s, 'HTTP response 200' );
    ok( $tmp =~ /<result xsi:type="xsd:string">SoapOK<\/result>/s,
        'result of SOAP call' );
}
