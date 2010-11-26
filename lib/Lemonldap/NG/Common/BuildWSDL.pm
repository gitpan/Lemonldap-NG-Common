## @file
# Utility to build WSDL files

## @class
# Class utility to build WSDL files
package Lemonldap::NG::Common::BuildWSDL;

use Lemonldap::NG::Common::Conf;

our $VERSION = '1.0.0';

## @cmethod Lemonldap::NG::Common::Conf new(hashref configStorage);
# Constructor
# @param $configStorage Configuration access parameters
# @return Lemonldap::NG::Common::Conf new object
sub new {
    my ( $class, $configStorage ) = @_;
    my $self = bless {}, $class;
    my $lmConf = Lemonldap::NG::Common::Conf->new($configStorage)
      or die($Lemonldap::NG::Common::Conf::msg);
    $self->{conf} = $lmConf->getConf() or die "Unable to load configuration";
    return $self;
}

## @method string buildWSDL(string xml)
# Parse XML string to sustitute macros
# @param $xml XML string
# @return Parsed XML string
sub buildWSDL {
    my ( $self, $xml ) = @_;
    my $portal = $self->{conf}->{portal};
    $portal .= "index.pl" if ( $portal =~ /\/$/ );
    $xml =~ s/__PORTAL__/$portal/gs;
    $xml =~ s/__DOMAIN__/$self->{conf}->{domain}/gs;

    # Cookies
    my @cookies = split /\s+/, $self->{conf}->{cookieName};
    s#(.*)#<element name="$1" type="xsd:string"></element># foreach (@cookies);
    $xml =~ s/__XMLCOOKIELIST__/join("\n",@cookies)/ges;

    # Attributes
    my @attr = (
        keys %{ $self->{conf}->{exportedVars} },
        keys %{ $self->{conf}->{macros} },
        qw(_timezone ipAddr _password authenticationLevel _session_id xForwardedForAddr startTime _user _utime dn)
    );
    s#(.*)#<element name="$1" type="xsd:string" nillable="true"></element>#
      foreach (@attr);
    $xml =~ s/__ATTRLIST__/join("\n",@attr)/ges;
    return $xml;
}

1;

