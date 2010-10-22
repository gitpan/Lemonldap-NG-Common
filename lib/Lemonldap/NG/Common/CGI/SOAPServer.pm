## @file
# SOAP support for Lemonldap::NG::Common::CGI

## @class
# Extend SOAP::Transport::HTTP::Server to be able to use posted datas catched
# by CGI module.
# All Lemonldap::NG cgi inherits from CGI so with this library, they can
# understand both browser and SOAP requests.
package Lemonldap::NG::Common::CGI::SOAPServer;
use SOAP::Transport::HTTP;
use base qw(SOAP::Transport::HTTP::Server);
use bytes;

our $VERSION = '0.99.1';

## @method protected void DESTROY()
# Call SOAP::Trace::objects().
sub DESTROY { SOAP::Trace::objects('()') }

## @cmethod Lemonldap::NG::Common::CGI::SOAPServer new(@param)
# @param @param SOAP::Transport::HTTP::Server::new() parameters
# @return Lemonldap::NG::Common::CGI::SOAPServer object
sub new {
    my $self = shift;
    return $self if ref $self;

    my $class = ref($self) || $self;
    $self = $class->SUPER::new(@_);
    SOAP::Trace::objects('()');

    return $self;
}

## @method void handle(CGI cgi)
# Build SOAP request using CGI->param('POSTDATA') and call
# SOAP::Transport::HTTP::Server::handle() then return the result to the client.
# @param $cgi CGI object
sub handle {
    my $self = shift->new;
    my $cgi  = shift;

    my $content = $cgi->param('POSTDATA');
    my $length  = bytes::length($content);

    if ( !$length ) {
        $self->response( HTTP::Response->new(411) )    # LENGTH REQUIRED
    }
    elsif ( defined $SOAP::Constants::MAX_CONTENT_SIZE
        && $length > $SOAP::Constants::MAX_CONTENT_SIZE )
    {
        $self->response( HTTP::Response->new(413) )   # REQUEST ENTITY TOO LARGE
    }
    else {
        $self->request(
            HTTP::Request->new(
                'POST' => $ENV{'SCRIPT_NAME'},
                HTTP::Headers->new(
                    map {
                        (
                              /^HTTP_(.+)/i
                            ? ( $1 =~ m/SOAPACTION/ )
                                  ? ('SOAPAction')
                                  : ($1)
                            : $_
                          ) => $ENV{$_}
                      } keys %ENV
                ),
                $content,
            )
        );
        $self->SUPER::handle();
    }

    print $cgi->header(
        -status => $self->response->code . " "
          . HTTP::Status::status_message( $self->response->code ),
        -type           => $self->response->header('Content-Type'),
        -Content_Length => $self->response->header('Content-Length'),
        -SOAPServer     => 'Lemonldap::NG CGI',
    );
    binmode( STDOUT, ":bytes" );
    print $self->response->content;
}

1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Common::CGI::SOAPServer - Extends L<SOAP::Lite> to be compatible
with L<CGI>.

=head1 SYNOPSIS

  use CGI;
  use Lemonldap::NG::Common::CGI::SOAPServer;
  
  my $cgi = CGI->new();
  Lemonldap::NG::Common::CGI::SOAPServer->dispatch_to('same as SOAP::Lite')
     ->handle($cgi)

=head1 DESCRIPTION

This extension just extend L<SOAP::Lite> handle() method to load datas from
a L<CGI> object instead of STDIN.

=head1 SEE ALSO

L<http://lemonldap.objectweb.org/>, L<Lemonldap::NG::Common::CGI>

=head1 AUTHOR

Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Xavier Guimard

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
