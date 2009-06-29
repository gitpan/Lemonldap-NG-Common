##@file
# Extend Crypt::Rijndael to add base64 encoding to cypher functions

##@class
# Extend Crypt::Rijndael to add base64 encoding to cypher functions.
# $Lemonldap::NG::Common::Crypto::msg contains Crypt::Rijndael errors.
package Lemonldap::NG::Common::Crypto;

use strict;
use Crypt::Rijndael;
use MIME::Base64;
use base qw(Crypt::Rijndael);

our $VERSION = '0.1';

our $msg;

## @cmethod Lemonldap::NG::Common::Crypto new(array param)
# Constructor
# @param @param Crypt::Rijndael::new() parameters
# @return Lemonldap::NG::Common::Crypto object
sub new {
    my $class = shift;
    my $self  = Crypt::Rijndael->new(@_);
    return bless $self, $class;
}

## @method string encrypt(string data)
# Encrypt $data and return it in Base64 format
# @param data datas to encrypt
# @return encrypted datas in Base64 format
sub encrypt {
    my $self = shift;
    my $tmp;
    eval { $tmp = encode_base64( $self->SUPER::encrypt(@_), '' ); };
    if ($@) {
        $msg = "Crypt::Rijndael error : $@";
        return undef;
    }
    else {
        $msg = '';
        return $tmp;
    }
}

## @method string decrypt(string data)
# Decrypt $data and return it in
# @param data datas to decrypt in Base64 format
# @return decrypted datas
sub decrypt {
    my $self = shift;
    my $tmp  = shift;
    $tmp =~ s/%2B/\+/ig;
    $tmp =~ s/%2F/\//ig;
    $tmp =~ s/%3D/=/ig;
    eval { $tmp = $self->SUPER::decrypt( decode_base64($tmp) ); };
    if ($@) {
        $msg = "Crypt::Rijndael error : $@";
        return undef;
    }
    else {
        $msg = '';
        return $tmp;
    }
}

1;
