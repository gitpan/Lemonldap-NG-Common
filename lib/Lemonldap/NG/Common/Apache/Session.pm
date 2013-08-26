## @file
# Add get_key_from_all_sessions() function to Apache::Session modules.
# This file is used by Lemonldap::NG::Manager::Status and by the
# purgeCentralCache script.
#
# Warning, this works only with SQL databases, simple or Berkeley files (not
# for Apache::Session::Memcached for example)
package Lemonldap::NG::Common::Apache::Session;

use strict;
use AutoLoader 'AUTOLOAD';
use Apache::Session;
use base qw(Apache::Session);

our $VERSION = '1.2.3';

sub _load {
    my $backend = shift;
    unless ( $backend->can('populate') ) {
        eval "require $backend";
        die $@ if ($@);
    }
}

sub populate {
    my $self    = shift;
    my $backend = $self->{args}->{backend};
    _load($backend);
    $backend .= "::populate";
    {
        no strict 'refs';
        $self = $self->$backend(@_);
    }
    if ( $self->{args}->{setId} ) {
        $self->{generate} = \&setId;
        $self->{validate} = sub { 1 };
    }
    return $self;
}

__END__

sub setId {
    my $session = shift;
    $session->{data}->{_session_id} = $session->{args}->{setId};
}

sub searchOn {
    my ( $class, $args, $selectField, $value, @fields ) = splice @_;
    my $backend = $args->{backend};
    _load($backend);
    if ( $backend->can('searchOn') ) {
        return $backend->searchOn( $args, $selectField, $value, @fields );
    }
    my %res = ();
    $class->get_key_from_all_sessions(
        $args,
        sub {
            my $entry = shift;
            my $id    = shift;
            return undef unless ( $entry->{$selectField} eq $value );
            if (@fields) {
                $res{$id}->{$_} = $entry->{$_} foreach (@fields);
            }
            else {
                $res{$id} = $entry;
            }
            undef;
        }
    );
    return \%res;
}

sub searchOnExpr {
    my ( $class, $args, $selectField, $value, @fields ) = splice @_;
    my $backend = $args->{backend};
    _load($backend);
    if ( $backend->can('searchOnExpr') ) {
        return $backend->searchOnExpr( $args, $selectField, $value, @fields );
    }
    $value = quotemeta($value);
    $value =~ s/\\\*/\.\*/g;
    $value = qr/^$value$/;
    my %res = ();
    $class->get_key_from_all_sessions(
        $args,
        sub {
            my $entry = shift;
            my $id    = shift;
            return undef unless ( $entry->{$selectField} =~ $value );
            if (@fields) {
                $res{$id}->{$_} = $entry->{$_} foreach (@fields);
            }
            else {
                $res{$id} = $entry;
            }
            undef;
        }
    );
    return \%res;
}

sub searchLt {
    my ( $class, $args, $selectField, $value, @fields ) = splice @_;
    my %res = ();
    $class->get_key_from_all_sessions(
        $args,
        sub {
            my $entry = shift;
            my $id    = shift;
            return undef unless ( $entry->{$selectField} < $value );
            if (@fields) {
                $res{$id}->{$_} = $entry->{$_} foreach (@fields);
            }
            else {
                $res{$id} = $entry;
            }
            undef;
        }
    );
    return \%res;
}

sub get_key_from_all_sessions {
    my $class = shift;

    #my ( $class, $args, $data ) = splice @_;
    my $backend = $_[0]->{backend};
    _load($backend);
    if ( $backend->can('get_key_from_all_sessions') ) {
        return $backend->get_key_from_all_sessions(@_);
    }
    if ( $backend =~
        /^Apache::Session::(MySQL|Postgres|Oracle|Sybase|Informix)$/ )
    {
        return $class->_dbiGKFAS( $1, @_ );
    }
    elsif ( $backend =~ /^Apache::Session::(?:NoSQL|Redis|Cassandra)$/ ) {
        return $class->_NoSQLGKFAS(@_);
    }
    elsif ( $backend =~ /^Apache::Session::(File|PHP|DBFile|LDAP)$/ ) {
        no strict 'refs';
        my $tmp = "_${1}GKFAS";
        return $class->$tmp(@_);
    }
    else {
        die "$backend can not provide session exploration";
    }
}

sub decodeThaw64 {
    require Storable;
    require MIME::Base64;
    my $s = shift;
    return Storable::thaw( MIME::Base64::decode_base64($s) );
}

sub _dbiGKFAS {
    my ( $class, $type, $args, $data ) = @_;
    my $unserialize;
    require Storable;
    if ( $type =~ /(?:MySQL)/ ) {
        $unserialize = \&Storable::thaw;
    }
    else {
        $unserialize = \&decodeThaw64;
    }

    my $dbh =
      DBI->connect( $args->{DataSource}, $args->{UserName}, $args->{Password} )
      or die("$!$@");
    my $sth = $dbh->prepare('SELECT id,a_session from sessions');
    $sth->execute;
    my %res;
    while ( my @row = $sth->fetchrow_array ) {
        if ( ref($data) eq 'CODE' ) {
            my $tmp = &$data( $unserialize->( $row[1] ), $row[0] );
            $res{ $row[0] } = $tmp if ( defined($tmp) );
        }
        elsif ($data) {
            $data = [$data] unless ( ref($data) );
            my $tmp = $unserialize->( $row[1] );
            $res{ $row[0] }->{$_} = $tmp->{$_} foreach (@$data);
        }
        else {
            $res{ $row[0] } = $unserialize->( $row[1] );
        }
    }
    return \%res;
}

sub _FileGKFAS {
    my ( $class, $args, $data ) = @_;
    $args->{Directory} ||= '/tmp';
    require Storable;

    unless ( opendir DIR, $args->{Directory} ) {
        die "Cannot open directory $args->{Directory}\n";
    }
    my @t =
      grep { -f "$args->{Directory}/$_" and /^[A-Za-z0-9@\-]+$/ } readdir(DIR);
    closedir DIR;
    my %res;
    for my $f (@t) {
        open F, "$args->{Directory}/$f";
        my $row = join '', <F>;
        if ( ref($data) eq 'CODE' ) {
            eval { $res{$f} = &$data( Storable::thaw($row), $f ); };
            if ($@) {
                $res{$f} = &$data( undef, $f );
            }
        }
        elsif ($data) {
            $data = [$data] unless ( ref($data) );
            my $tmp;
            eval { $tmp = Storable::thaw($row); };
            if ($@) {
                $res{$f}->{$_} = undef foreach (@$data);
            }
            else {
                $res{$f}->{$_} = $tmp->{$_} foreach (@$data);
            }
        }
        else {
            eval { $res{$f} = Storable::thaw($row); };
        }
    }
    return \%res;
}

sub _PHPGKFAS {
    require Apache::Session::Serialize::PHP;
    my ( $class, $args, $data ) = @_;

    my $directory = $args->{SavePath} || '/tmp';
    unless ( opendir DIR, $args->{SavePath} ) {
        die "Cannot open directory $args->{SavePath}\n";
    }
    my @t =
      grep { -f "$args->{SavePath}/$_" and /^sess_[A-Za-z0-9@\-]+$/ }
      readdir(DIR);
    closedir DIR;
    my %res;
    for my $f (@t) {
        open F, "$args->{SavePath}/$f";
        my $row = join '', <F>;
        if ( ref($data) eq 'CODE' ) {
            $res{$f} =
              &$data( Apache::Session::Serialize::PHP::unserialize($row), $f );
        }
        elsif ($data) {
            $data = [$data] unless ( ref($data) );
            my $tmp = Apache::Session::Serialize::PHP::unserialize($row);
            $res{$f}->{$_} = $tmp->{$_} foreach (@$data);
        }
        else {
            $res{$f} = Apache::Session::Serialize::PHP::unserialize($row);
        }
    }
    return \%res;
}

sub _DBFileGKFAS {
    my ( $class, $args, $data ) = @_;
    require Storable;

    if ( !tied %{ $class->{dbm} } ) {
        my $rv = tie %{ $class->{dbm} }, 'DB_File', $args->{FileName};
        if ( !$rv ) {
            die "Could not open dbm file " . $args->{FileName} . ": $!";
        }
    }

    my %res;
    foreach my $k ( keys %{ $class->{dbm} } ) {
        if ( ref($data) eq 'CODE' ) {
            $res{$k} = &$data( Storable::thaw( $class->{dbm}->{$k} ), $k );
        }
        elsif ($data) {
            $data = [$data] unless ( ref($data) );
            my $tmp = Storable::thaw( $class->{dbm}->{$k} );
            $res{$k}->{$_} = $tmp->{$_} foreach (@$data);
        }
        else {
            $res{$k} = Storable::thaw( $class->{dbm}->{$k} );
        }
    }
    return \%res;
}

sub _LDAPGKFAS {
    my ( $class, $args, $data ) = @_;

    my $ldap = Apache::Session::Store::LDAP::ldap( { args => $args } );
    my $msg = $ldap->search(
        base   => $args->{ldapConfBase},
        filter => '(objectClass=applicationProcess)',
        attrs  => [ 'cn', 'description' ],
    );
    Apache::Session::Store::LDAP->logError($msg) if ( $msg->code );
    my %res;
    foreach my $entry ( $msg->entries ) {
        my ( $k, $v ) =
          ( $entry->get_value('cn'), $entry->get_value('description') );
        eval { $v = decodeThaw64($v); };
        next if ($@);
        if ( ref($data) eq 'CODE' ) {
            $res{$k} = &$data( $v, $k );
        }
        elsif ($data) {
            $data = [$data] unless ( ref($data) );
            my $tmp = $v;
            $res{$k}->{$_} = $tmp->{$_} foreach (@$data);
        }
        else {
            $res{$k} = $v;
        }
    }
    return \%res;
}

sub _NoSQLGKFAS {
    my ( $class, $args, $data ) = @_;
    require Redis;
    die "Only Redis is supported" unless ( $args->{Driver} eq 'Redis' );
    my $redis = Redis->new(%$args);
    my @keys  = $redis->keys('*');
    my %res;

    foreach my $k (@keys) {
        my $v = eval { decodeThaw64( $redis->get($k) ); };
        next if ($@);
        if ( ref($data) eq 'CODE' ) {
            $res{$k} = &$data( $v, $k );
        }
        elsif ($data) {
            $data = [$data] unless ( ref($data) );
            $res{$k}->{$_} = $v->{$_} foreach (@$data);
        }
        else {
            $res{$k} = $v;
        }
    }
    return \%res;
}

1;
