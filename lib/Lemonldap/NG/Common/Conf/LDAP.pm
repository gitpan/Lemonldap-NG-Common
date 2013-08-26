##@file
# LDAP configuration backend

##@class
# Implements LDAP backend for Lemonldap::NG
package Lemonldap::NG::Common::Conf::LDAP;

use strict;
use Net::LDAP;
use Lemonldap::NG::Common::Conf::Constants;    #inherits
use Lemonldap::NG::Common::Conf::Serializer;
use Encode;

our $VERSION = '1.2.5';

BEGIN {
    *Lemonldap::NG::Common::Conf::ldap = \&ldap;
}

sub prereq {
    my $self = shift;
    foreach ( 'ldapServer', 'ldapConfBase', 'ldapBindDN', 'ldapBindPassword' ) {
        unless ( $self->{$_} ) {
            $Lemonldap::NG::Common::Conf::msg .=
              "$_ is required in LDAP configuration type \n";
            return 0;
        }
    }
    1;
}

sub available {
    my $self = shift;

    unless ( $self->ldap ) {
        return 0;
    }

    my $search = $self->ldap->search(
        base   => $self->{ldapConfBase},
        filter => '(objectClass=applicationProcess)',
        scope  => 'one',
        attrs  => ['cn'],
    );

    if ( $search->code ) {
        $self->logError($search);
        return 0;
    }

    my @entries = $search->entries();
    my @conf;
    foreach (@entries) {
        my $cn = $_->get_value('cn');
        my ($cfgNum) = ( $cn =~ /lmConf-(\d*)/ );
        push @conf, $cfgNum;
    }
    $self->ldap->unbind() && delete $self->{ldap};
    return sort { $a <=> $b } @conf;
}

sub lastCfg {
    my $self  = shift;
    my @avail = $self->available;
    return $avail[$#avail];
}

sub ldap {
    my $self = shift;
    return $self->{ldap} if ( $self->{ldap} );

    # Parse servers configuration
    my $useTls = 0;
    my $tlsParam;
    my @servers = ();
    foreach my $server ( split /[\s,]+/, $self->{ldapServer} ) {
        if ( $server =~ m{^ldap\+tls://([^/]+)/?\??(.*)$} ) {
            $useTls   = 1;
            $server   = $1;
            $tlsParam = $2 || "";
        }
        else {
            $useTls = 0;
        }
        push @servers, $server;
    }

    # Connect
    my $ldap = Net::LDAP->new(
        \@servers,
        onerror => undef,
        ( $self->{ldapPort} ? ( port => $self->{ldapPort} ) : () ),
    );

    unless ($ldap) {
        $Lemonldap::NG::Common::Conf::msg .= "$@\n";
        return;
    }

    # Start TLS if needed
    if ($useTls) {
        my %h = split( /[&=]/, $tlsParam );
        $h{cafile} = $self->{caFile} if ( $self->{caFile} );
        $h{capath} = $self->{caPath} if ( $self->{caPath} );
        my $start_tls = $ldap->start_tls(%h);
        if ( $start_tls->code ) {
            $self->logError($start_tls);
            return;
        }
    }

    # Bind with credentials
    my $bind =
      $ldap->bind( $self->{ldapBindDN}, password => $self->{ldapBindPassword} );
    if ( $bind->code ) {
        $self->logError($bind);
        return;
    }

    $self->{ldap} = $ldap;
    return $ldap;
}

sub lock {

    # No lock for LDAP
    return 1;
}

sub isLocked {

    # No lock for LDAP
    return 0;
}

sub unlock {

    # No lock for LDAP
    return 1;
}

sub store {
    my ( $self, $fields ) = @_;

    unless ( $self->ldap ) {
        return 0;
    }

    $fields = $self->serialize($fields);

    my $confName = "lmConf-" . $fields->{cfgNum};
    my $confDN   = "cn=$confName," . $self->{ldapConfBase};

    # Store values as {key}value
    my @confValues;
    while ( my ( $k, $v ) = each(%$fields) ) {
        $v = encodeLdapValue($v);
        push @confValues, "{$k}$v";
    }

    my $add = $self->ldap->add(
        $confDN,
        attrs => [
            objectClass => [ 'top', 'applicationProcess' ],
            cn          => $confName,
            description => \@confValues,
        ]
    );

    if ( $add->code ) {
        $self->logError($add);
        return 0;
    }

    $self->ldap->unbind() && delete $self->{ldap};
    $self->unlock;
    return $fields->{cfgNum};
}

sub load {
    my ( $self, $cfgNum, $fields ) = @_;

    unless ( $self->ldap ) {
        return;
    }

    my $f;
    my $confName = "lmConf-" . $cfgNum;
    my $confDN   = "cn=$confName," . $self->{ldapConfBase};

    my $search = $self->ldap->search(
        base   => $confDN,
        filter => '(objectClass=applicationProcess)',
        scope  => 'base',
        attrs  => ['description'],
    );

    if ( $search->code ) {
        $self->logError($search);
        return;
    }

    my $entry      = $search->shift_entry();
    my @confValues = $entry->get_value('description');
    foreach (@confValues) {
        my ( $k, $v ) = ( $_ =~ /\{(.*?)\}(.*)/ );
        $v = decodeLdapValue($v);
        if ($fields) {
            $f->{$k} = $v if ( grep { $_ eq $k } @$fields );
        }
        else {
            $f->{$k} = $v;
        }
    }
    $self->ldap->unbind() && delete $self->{ldap};
    return $self->unserialize($f);
}

sub delete {
    my ( $self, $cfgNum ) = @_;

    unless ( $self->ldap ) {
        return 0;
    }

    my $confDN = "cn=lmConf-" . $cfgNum . "," . $self->{ldapConfBase};
    my $delete = $self->ldap->delete($confDN);
    $self->ldap->unbind() && delete $self->{ldap};
    $self->logError($delete) if ( $delete->code );
}

sub logError {
    my $self           = shift;
    my $ldap_operation = shift;
    $Lemonldap::NG::Common::Conf::msg .=
        "LDAP error "
      . $ldap_operation->code . ": "
      . $ldap_operation->error . " \n";
}

# Helpers to have UTF-8 values in LDAP
# and default encoding in configuration object
sub encodeLdapValue {
    my $value = shift;

    eval {
        my $safevalue = $value;
        Encode::from_to( $safevalue, "utf8", "iso-8859-1", Encode::FB_CROAK );
    };
    if ($@) {
        Encode::from_to( $value, "iso-8859-1", "utf8", Encode::FB_CROAK );
    }

    return $value;

}

sub decodeLdapValue {
    my $value = shift;

    Encode::from_to( $value, "utf8", "iso-8859-1", Encode::FB_CROAK );

    return $value;

}

1;
__END__
