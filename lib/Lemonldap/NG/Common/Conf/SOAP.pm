package Lemonldap::NG::Common::Conf::SOAP;

use strict;
use SOAP::Lite;

our $VERSION = '0.99.1';

#parameter proxy Url of SOAP service
#parameter proxyOptions SOAP::Lite parameters

BEGIN {
    *Lemonldap::NG::Common::Conf::_soapCall = \&_soapCall;
    *Lemonldap::NG::Common::Conf::_connect  = \&_connect;

    sub SOAP::Transport::HTTP::Client::get_basic_credentials {
        return $Lemonldap::NG::Common::Conf::SOAP::username =>
          $Lemonldap::NG::Common::Conf::SOAP::password;
    }
}

our ( $username, $password ) = ( '', '' );

sub prereq {
    my $self = shift;
    unless ( $self->{proxy} ) {
        $Lemonldap::NG::Common::Conf::msg =
          '"proxy" parameter is required in "SOAP" configuration type';
        return 0;
    }
    1;
}

sub _connect {
    my $self = shift;
    return $self->{service} if ( $self->{service} );
    my @args = ( $self->{proxy} );
    if ( $self->{proxyOptions} ) {
        push @args, %{ $self->{proxyOptions} };
    }
    $self->{ns} ||= 'urn:/Lemonldap/NG/Common/CGI/SOAPService';
    return $self->{service} = SOAP::Lite->ns( $self->{ns} )->proxy(@args);
}

sub _soapCall {
    my $self = shift;
    my $func = shift;
    $username = $self->{User};
    $password = $self->{Password};
    my $r = $self->_connect->$func(@_);
    if ( $r->fault() ) {
        print STDERR "SOAP error : " . $r->fault()->{faultstring};
        return ();
    }
    return $r->result;
}

sub available {
    my $self = shift;
    return @{ $self->_soapCall( 'available', @_ ) };
}

sub lastCfg {
    my $self = shift;
    return $self->_soapCall( 'lastCfg', @_ );
}

sub lock {
    my $self = shift;
    return $self->_soapCall( 'lock', @_ );
}

# unlock is not needed here since real unlock is called by store
#sub unlock {
#    my $self = shift;
#    return $self->_soapCall( 'unlock', @_ );
#}

sub isLocked {
    my $self = shift;
    return $self->_soapCall( 'isLocked', @_ );
}

sub store {
    my $self = shift;
    return $self->_soapCall( 'store', @_ );
}

sub load {
    my $self = shift;
    return $self->_soapCall( 'getConfig', @_ );
}

1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Common::Conf::SOAP - Perl extension written to access to
Lemonldap::NG Web-SSO configuration via SOAP.

=head1 SYNOPSIS

=head2 Client side

=head3 Area protection (Apache handler)

  package My::Package;
  
  use base Lemonldap::NG::Handler::SharedConf;
  
  __PACKAGE__->init ( {
      localStorage        => "Cache::FileCache",
      localStorageOptions => {
                'namespace'          => 'MyNamespace',
                'default_expires_in' => 600,
      },
      configStorage       => {
                type     => 'SOAP',
                proxy    => 'http://auth.example.com/index.pl/config',
                # If soapserver is protected by HTTP Basic:
                User     => 'http-user',
                Password => 'pass',
      },
      https               => 0,
  } );

=head3 Authentication portal

  use Lemonldap::NG::Portal::SharedConf;
  
  my $portal = Lemonldap::NG::Portal::SharedConf->new ( {
          configStorage => {
                  type    => 'SOAP',
                  proxy    => 'http://auth.example.com/index.pl/config',
                  # If soapserver is protected by HTTP Basic:
                  User     => 'http-user',
                  Password => 'pass',
          }
  });
  # Next as usual... See Lemonldap::NG::Portal(3)
  if($portal->process()) {
    ...

=head3 Manager

  use Lemonldap::NG::Manager;
  
  my $m=new Lemonldap::NG::Manager(
       {
           configStorage=>{
                  type  => 'SOAP',
                  proxy    => 'http://auth.example.com/index.pl/config',
                  # If soapserver is protected by HTTP Basic:
                  User     => 'http-user',
                  Password => 'pass',
           },
            dhtmlXTreeImageLocation=> "/imgs/",
        }
  ) or die "Unable to start manager";
  
  $m->doall();

=head2 Server side

You just have to set "Soap => 1" in your portal. See HTML documentation for
more.

=head1 DESCRIPTION

Lemonldap::NG::Common::Conf provides a simple interface to access to
Lemonldap::NG Web-SSO configuration. It is used by L<Lemonldap::NG::Handler>,
L<Lemonldap::NG::Portal> and L<Lemonldap::NG::Manager>.

Lemonldap::NG::Common::Conf::SOAP provides the "SOAP" target used to access
configuration via SOAP.

=head2 SECURITY

As Lemonldap::NG::Common::Conf::SOAP use SOAP::Lite, you have to see
L<SOAP::Transport> to know arguments that can be passed to C<proxyOptions>.
Lemonldap::NG provides a system for HTTP basic authentication.

Examples :

=over

=item * HTTP Basic authentication

  package My::Package;
  
  use base Lemonldap::NG::Handler::SharedConf;
  
  __PACKAGE__->init ( {
      localStorage        => "Cache::FileCache",
      localStorageOptions => {
                'namespace'          => 'MyNamespace',
                'default_expires_in' => 600,
      },
      configStorage       => {
                type  => 'SOAP',
                proxy => 'http://auth.example.com/index.pl/config',
                User     => 'http-user',
                Password => 'pass',
      },
      https               => 1,
  } );

=item * SSL Authentication

SOAP::transport provides a simple way to use SSL certificate: you've just to
set environment variables.

  package My::Package;
  
  use base Lemonldap::NG::Handler::SharedConf;
  
  # AUTHENTICATION
  $ENV{HTTPS_CERT_FILE} = 'client-cert.pem';
  $ENV{HTTPS_KEY_FILE}  = 'client-key.pem';
  
  __PACKAGE__->init ( {
      localStorage        => "Cache::FileCache",
      localStorageOptions => {
                'namespace'          => 'MyNamespace',
                'default_expires_in' => 600,
      },
      configStorage       => {
                type  => 'SOAP',
                proxy => 'http://auth.example.com/index.pl/config',
      },
      https               => 1,
  } );

=back

=head1 SEE ALSO

L<Lemonldap::NG::Common::Conf::SOAP>,
L<Lemonldap::NG::Handler>, L<Lemonldap::NG::Portal>,
http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/Presentation

=head1 AUTHOR

Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<http://forge.objectweb.org/tracker/?group_id=274>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<http://forge.objectweb.org/project/showfiles.php?group_id=274>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Xavier Guimard

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
