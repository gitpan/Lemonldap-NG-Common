## @file
# Base package for all Lemonldap::NG CGI

## @class
# Base class for all Lemonldap::NG CGI
package Lemonldap::NG::Common::CGI;

use strict;

use MIME::Base64;
use Time::Local;
use CGI;

our $VERSION = '0.4';

use base qw(CGI);

## @method void soapTest(string soapFunctions object obj)
# Check if request is a SOAP request. If it is, launch
# Lemonldap::NG::Common::CGI::SOAPServer and exit. Else simply return.
# @param $soapFunctions list of authorized functions.
# @param $obj optional object that will receive SOAP requests
sub soapTest {
    my($self, $soapFunctions, $obj) = @_;

    # If non form encoded datas are posted, we call SOAP Services
    if ( $ENV{HTTP_SOAPACTION} ) {
        require Lemonldap::NG::Common::CGI::SOAPServer; #link protected dispatcher
        require Lemonldap::NG::Common::CGI::SOAPService; #link protected soapService
        my @func = ( ref($soapFunctions) ? @$soapFunctions : split /\s+/, $soapFunctions );
        my $dispatcher = Lemonldap::NG::Common::CGI::SOAPService->new($obj||$self,@func);
        Lemonldap::NG::Common::CGI::SOAPServer->dispatch_to($dispatcher)
          ->handle($self);
        exit;
    }
}

## @method string header_public(string filename)
# Implements the "304 Not Modified" HTTP mechanism.
# If HTTP request contains an "If-Modified-Since" header and if
# $filename was not modified since, prints the "304 Not Modified" response and
# exit. Else, launch CGI::header() with "Cache-Control" and "Last-Modified"
# headers.
# @param $filename Optional name of the reference file. Default
# $ENV{SCRIPT_FILENAME}.
# @return Common Gateway Interface standard response header
sub header_public {
    my $self     = shift;
    my $filename = shift;
    $filename ||= $ENV{SCRIPT_FILENAME};
    my @tmp  = stat($filename);
    my $date = $tmp[9];
    my $hd   = gmtime($date);
    $hd =~ s/^(\w+)\s+(\w+)\s+(\d+)\s+([\d:]+)\s+(\d+)$/$1, $3 $2 $5 $4 GMT/;
    my $year = $5;
    my $cm   = $2;

    # TODO: Remove TODO_ for stable releases
    if ( my $ref = $ENV{HTTP_IF_MODIFIED_SINCE} ) {
        my %month = (
            jan => 0,
            feb => 1,
            mar => 2,
            apr => 3,
            may => 4,
            jun => 5,
            jul => 6,
            aug => 7,
            sep => 8,
            oct => 9,
            nov => 10,
            dec => 11
        );
        if ( $ref =~ /^\w+,\s+(\d+)\s+(\w+)\s+(\d+)\s+(\d+):(\d+):(\d+)/ ) {
            my $m = $month{ lc($2) };
            $year-- if ( $m > $month{ lc($cm) } );
            $ref = timegm( $6, $5, $4, $1, $m, $3 );
            if ( $ref == $date ) {
                print $self->SUPER::header( -status => '304 Not Modified', @_ );
                exit;
            }
        }
    }
    return $self->SUPER::header(
        '-Last-Modified' => $hd,
        '-Cache-Control' => 'public; must-revalidate; max-age=1800',
        @_
    );
}

## @method void abort(string title, string text)
# Display an error message and exit.
# Used instead of die() in Lemonldap::NG CGIs.
# @param title Title of the error message
# @param text Optional text. Default: "See Apache's logs"
sub abort {
    my $self = shift;
    my $cgi  = CGI->new;
    my ( $t1, $t2 ) = @_;
    $t2 ||= "See Apache's logs";
    print $cgi->header(
        -type    => 'text/html; charset=utf8',
    );
    print $cgi->start_html(
        -title    => $t1,
        -encoding => 'utf8',
    );
    print "<h1>$t1</h1>";
    print "<p>$t2</p>";
    print STDERR ( ref($self)|| $self ) . " error: $t1, $t2\n";
    exit;
}

1;

__END__

=head1 NAME

Lemonldap::NG::Common::CGI - Simple module to extend L<CGI> to manage
HTTP "If-Modified-Since / 304 Not Modified" system.

=head1 SYNOPSIS

  use Lemonldap::NG::Common::CGI;
  
  my $cgi = Lemonldap::NG::Common::CGI->new();
  $cgi->header_public($ENV{SCRIPT_FILENAME});
  print "<html><head><title>Static page</title></head>";
  ...

=head1 DESCRIPTION

Lemonldap::NG::Common::CGI just add header_public subroutine to CGI module to
avoid printing HTML elements that can be cached.

=head1 METHODS

=head2 header_public

header_public works like header (see L<CGI>) but the first argument has to be
a filename: the last modify date of this file is used for reference.

=head2 EXPORT

=head1 SEE ALSO

L<Lemonldap::NG::Manager>, L<CGI>,
http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/Presentation

=head1 AUTHOR

Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006-2007 by Xavier Guimard E<lt>x.guimard@free.frE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.

=cut
