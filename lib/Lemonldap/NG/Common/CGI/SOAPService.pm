## @file
# SOAP wrapper used to restrict exported functions

## @class
# SOAP wrapper used to restrict exported functions
package Lemonldap::NG::Common::CGI::SOAPService;

## @cmethod Lemonldap::NG::Common::CGI::SOAPService new(object obj,string @func)
# Constructor
# @param $obj object which will be called for SOAP authorizated methods
# @param @fung authorizated methods
# @return Lemonldap::NG::Common::CGI::SOAPService object
sub new {
    my($class, $obj, @func) = @_;
    s/.*::// foreach(@func);
    return bless {obj=>$obj,func=>\@func}, $class;
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
    if(grep {$_ eq $AUTOLOAD} @{$self->{func}}){
        return $self->{obj}->$AUTOLOAD(@_);
    }
    elsif($AUTOLOAD ne 'DESTROY') {
        die "$AUTOLOAD is an authorizated function";use Data::Dumper;
    }
    1;
}

1;

