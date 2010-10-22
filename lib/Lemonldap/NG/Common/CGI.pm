## @file
# Base package for all Lemonldap::NG CGI

## @class
# Base class for all Lemonldap::NG CGI
package Lemonldap::NG::Common::CGI;

use strict;

use MIME::Base64;
use Time::Local;
use CGI;
use utf8;

#parameter syslog Indicates syslog facility for logging user actions

our $VERSION = '0.99.1';

use base qw(CGI);

BEGIN {
    if ( exists $ENV{MOD_PERL} ) {
        if ( $ENV{MOD_PERL_API_VERSION} and $ENV{MOD_PERL_API_VERSION} >= 2 ) {
            eval 'use constant MP => 2;';
        }
        else {
            eval 'use constant MP => 1;';
        }
    }
    else {
        eval 'use constant MP => 0;';
    }
}

## @cmethod Lemonldap::NG::Common::CGI new(@p)
# Constructor: launch CGI::new() then secure parameters since CGI store them at
# the root of the object.
# @param p arguments for CGI::new()
# @return new Lemonldap::NG::Common::CGI object
sub new {
    my $class = shift;
    my $self  = CGI->new(@_);
    $self->{_prm} = {};
    my @tmp = $self->param();
    foreach (@tmp) {
        $self->{_prm}->{$_} = $self->param($_);
        $self->delete($_);
    }
    bless $self, $class;
    return $self;
}

## @method scalar param(string s, scalar newValue)
# Return the wanted parameter issued of GET or POST request. If $s is not set,
# return the list of parameters names
# @param $s name of the parameter
# @param $newValue if set, the parameter will be set to his value
# @return datas passed by GET or POST method
sub param {
    my ( $self, $p, $v ) = @_;
    $self->{_prm}->{$p} = $v if ($v);
    unless ( defined $p ) {
        return keys %{ $self->{_prm} };
    }
    return $self->{_prm}->{$p};
}

## @method scalar rparam(string s)
# Return a reference to a parameter
# @param $s name of the parameter
# @return ref to parameter data
sub rparam {
    my ( $self, $p ) = @_;
    return $self->{_prm}->{$p} ? \$self->{_prm}->{$p} : undef;
}

## @method void lmLog(string mess, string level)
# Log subroutine. Use Apache::Log in ModPerl::Registry context else simply
# print on STDERR non debug messages.
# @param $mess Text to log
# @param $level Level (debug|info|notice|error)
sub lmLog {
    my ( $self, $mess, $level ) = @_;
    my $call;
    if ( $level eq 'debug' ) {
        $mess = ( ref($self) ? ref($self) : $self ) . ": $mess";
    }
    else {
        my @tmp = caller();
        $call = "$tmp[1] $tmp[2]:";
    }
    if ( $self->r and MP() ) {
        $self->abort( "Level is required",
            'the parameter "level" is required when lmLog() is used' )
          unless ($level);
        if ( MP() == 2 ) {
            require Apache2::Log;
            Apache2::ServerRec->log->debug($call) if ($call);
            Apache2::ServerRec->log->$level($mess);
        }
        else {
            Apache->server->log->debug($call) if ($call);
            Apache->server->log->$level($mess);
        }
    }
    else {
        $self->{hideLogLevels} = 'debug|info'
          unless defined( $self->{hideLogLevels} );
        my $re = qr/^(?:$self->{hideLogLevels})$/;
        print STDERR "$call\n" if ( $call and 'debug' !~ $re );
        print STDERR "[$level] $mess\n" unless ( $level =~ $re );
    }
}

## @method void setApacheUser(string user)
# Set user for Apache logs in ModPerl::Registry context. Does nothing else.
# @param $user data to set as user in Apache logs
sub setApacheUser {
    my ( $self, $user ) = @_;
    if ( $self->r and MP() ) {
        $self->lmLog( "Inform Apache about the user connected", 'debug' );
        if ( MP() == 2 ) {
            require Apache2::Connection;
            $self->r->user($user);
        }
        else {
            $self->r->connection->user($user);
        }
    }
    $ENV{REMOTE_USER} = $user;
}

## @method void soapTest(string soapFunctions, object obj)
# Check if request is a SOAP request. If it is, launch
# Lemonldap::NG::Common::CGI::SOAPServer and exit. Else simply return.
# @param $soapFunctions list of authorized functions.
# @param $obj optional object that will receive SOAP requests
sub soapTest {
    my ( $self, $soapFunctions, $obj ) = @_;

    # If non form encoded datas are posted, we call SOAP Services
    if ( $ENV{HTTP_SOAPACTION} ) {
        require
          Lemonldap::NG::Common::CGI::SOAPServer;    #link protected dispatcher
        require
          Lemonldap::NG::Common::CGI::SOAPService;   #link protected soapService
        my @func = (
            ref($soapFunctions) ? @$soapFunctions : split /\s+/,
            $soapFunctions
        );
        my $dispatcher =
          Lemonldap::NG::Common::CGI::SOAPService->new( $obj || $self, @func );
        Lemonldap::NG::Common::CGI::SOAPServer->dispatch_to($dispatcher)
          ->handle($self);
        $self->quit();
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
    my $cgi  = CGI->new();
    my ( $t1, $t2 ) = @_;
    $t2 ||= "See Apache's logs";
    print $cgi->header( -type => 'text/html; charset=utf8', );
    print $cgi->start_html(
        -title    => $t1,
        -encoding => 'utf8',
        -style    => {
            -code => '
body{
	background:#000;
	color:#fff;
	padding:10px 50px;
	font-family:sans-serif;
}
        '
        },
    );
    print "<h1>$t1</h1><p>$t2</p>";
    print
'<center><img alt="Lemonldap::NG" src="http://lemonldap.ow2.org/logo_lemonldap-ng.png" /></center>';
    print STDERR ( ref($self) || $self ) . " error: $t1, $t2\n";
    exit;
}

##@method private void startSyslog()
# Open syslog connection.
sub startSyslog {
    my $self = shift;
    return if ( $self->{_syslog} );
    eval {
        require Sys::Syslog;
        Sys::Syslog->import(':standard');
        openlog( 'lemonldap-ng', 'ndelay', $self->{syslog} );
    };
    $self->abort( "Unable to use syslog", $@ ) if ($@);
    $self->{_syslog} = 1;
}

##@method void userLog(string mess, string level)
# Log user actions on Apache logs or syslog.
# @param $mess string to log
# @param $level level of log message
sub userLog {
    my ( $self, $mess, $level ) = @_;
    if ( $self->{syslog} ) {
        $self->startSyslog();
        syslog( 'notice', $mess );
    }
    else {
        $self->lmLog( $mess, $level );
    }
}

##@method void userInfo(string mess)
# Log non important user actions. Alias for userLog() with facility "info".
# @param $mess string to log
sub userInfo {
    my ( $self, $mess ) = @_;
    $mess = "Lemonldap::NG : $mess ($ENV{REMOTE_ADDR})";
    $self->userLog( $mess, 'info' );
}

##@method void userNotice(string mess)
# Log user actions like access and logout. Alias for userLog() with facility
# "warn".
# @param $mess string to log
sub userNotice {
    my ( $self, $mess ) = @_;
    $mess = "Lemonldap::NG : $mess ($ENV{REMOTE_ADDR})";
    $self->userLog( $mess, 'notice' );
}

##@method void userError(string mess)
# Log user errors like "bad password". Alias for userLog() with facility
# "error".
# @param $mess string to log
sub userError {
    my ( $self, $mess ) = @_;
    $mess = "Lemonldap::NG : $mess ($ENV{REMOTE_ADDR})";
    $self->userLog( $mess, 'warn' );
}

## @method protected scalar _sub(string sub, array p)
# Launch $self->{$sub} if defined, else launch $self->$sub.
# @param $sub name of the sub to launch
# @param @p parameters for the sub
sub _sub {
    my ( $self, $sub, @p ) = @_;
    if ( $self->{$sub} ) {
        $self->lmLog( "processing to custom sub $sub", 'debug' );
        return &{ $self->{$sub} }( $self, @p );
    }
    else {
        $self->lmLog( "processing to sub $sub", 'debug' );
        return $self->$sub(@p);
    }
}

##@method void translate_template(string text_ref, string lang)
# translate_template is used as an HTML::Template filter to tranlate strings in
# the wanted language
#@param text_ref reference to the string to translate
#@param lang optionnal language wanted. Falls to browser language instead.
#@return
sub translate_template {
    my $self     = shift;
    my $text_ref = shift;
    my $lang     = shift || $ENV{HTTP_ACCEPT_LANGUAGE};

    # Get the lang code (2 letters)
    $lang = lc($lang);
    $lang =~ s/-/_/g;
    $lang =~ s/^(..).*$/$1/;

    # Decode UTF-8
    utf8::decode($$text_ref);

    # Test if a translation is available for the selected language
    # If not available, return the first translated string
    # <lang en="Please enter your credentials" fr="Merci de vous autentifier"/>
    if ( $$text_ref =~ m/$lang=\"(.*?)\"/ ) {
        $$text_ref =~ s/<lang.*$lang=\"(.*?)\".*?\/>/$1/gx;
    }
    else {
        $$text_ref =~ s/<lang\s+\w+=\"(.*?)\".*?\/>/$1/gx;
    }
}

## @method private void quit()
# Simply exit.
sub quit {
    exit;
}

1;

__END__

=head1 NAME

=encoding utf8

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
