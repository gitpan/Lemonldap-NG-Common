## @file
# SOAP support for Lemonldap::NG::Common::CGI

## @class
# SOAP support for Lemonldap::NG::Common::CGI
package Lemonldap::NG::Common::CGI::SOAPServer;
use SOAP::Transport::HTTP;
use base qw(SOAP::Transport::HTTP::Server);

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

## @method handle(CGI cgi)
# 
sub handle {
    my $self = shift->new;
    my $cgi  = shift;

    my $content = $cgi->param('POSTDATA');
    my $length  = length($content);

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
    print $self->response->content;
}

1;
__END__

