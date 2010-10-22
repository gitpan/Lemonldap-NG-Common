## @file
# SOAP wrapper used to restrict exported functions

## @class
# SOAP wrapper used to restrict exported functions
package Lemonldap::NG::Common::CGI::SOAPService;

require SOAP::Lite;

our $VERSION = '0.99.1';

## @cmethod Lemonldap::NG::Common::CGI::SOAPService new(object obj,string @func)
# Constructor
# @param $obj object which will be called for SOAP authorizated methods
# @param @func authorizated methods
# @return Lemonldap::NG::Common::CGI::SOAPService object
sub new {
    my ( $class, $obj, @func ) = @_;
    s/.*::// foreach (@func);
    return bless { obj => $obj, func => \@func }, $class;
}

## @method datas AUTOLOAD()
# Call the wanted function with the object given to the constructor.
# AUTOLOAD() is a magic method called by Perl interpreter fon non existent
# functions. Here, we use it to call the wanted function (given by $AUTOLOAD)
# if it is authorizated
# @return datas provided by the exported function
sub AUTOLOAD {
    my $self = shift;
    $AUTOLOAD =~ s/.*:://;
    if ( grep { $_ eq $AUTOLOAD } @{ $self->{func} } ) {
        my $tmp = $self->{obj}->$AUTOLOAD(@_);
        unless ( ref($tmp) and ref($tmp) eq 'SOAP::Data' ) {
            $tmp = SOAP::Data->name( result => $tmp );
        }
        return $tmp;
    }
    elsif ( $AUTOLOAD ne 'DESTROY' ) {
        die "$AUTOLOAD is not an authorizated function";
    }
    1;
}

1;

__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Common::CGI::SOAPService - Wrapper for all SOAP functions of
Lemonldap::NG CGIs.

=head1 SYNOPSIS

See L<Lemonldap::NG::Common::CGI>

=head1 DESCRIPTION

Private class used by L<Lemonldap::NG::Common::CGI> to control SOAP functions
access.

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
