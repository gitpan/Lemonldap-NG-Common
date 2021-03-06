package Lemonldap::NG::Common::Conf::CDBI;

use strict;
require Storable;
use Lemonldap::NG::Common::Conf::_DBI;

our $VERSION = '1.4.0';
our @ISA     = qw(Lemonldap::NG::Common::Conf::_DBI);

sub store {
    my ( $self, $fields ) = @_;
    my $cfgNum = $fields->{cfgNum};
    my $req;
    my $lastCfg = $self->lastCfg;

    $fields = Storable::nfreeze($fields);

    if ( $lastCfg == $cfgNum ) {
        $req = $self->_dbh->prepare(
            "UPDATE $self->{dbiTable} SET data=? WHERE cfgNum=?");
    }
    else {
        $req = $self->_dbh->prepare(
            "INSERT INTO $self->{dbiTable} (data,cfgNum) VALUES (?,?)");
    }
    unless ($req) {
        $self->logError;
        return UNKNOWN_ERROR;
    }
    unless ( $req->execute( $fields, $cfgNum ) ) {
        $self->logError;
        return UNKNOWN_ERROR;
    }
    eval { $self->_dbh->do("COMMIT"); };
    return $cfgNum;
}

sub load {
    my ( $self, $cfgNum, $fields ) = @_;
    $fields = $fields ? join( ",", @$fields ) : '*';
    my $row = $self->_dbh->selectrow_arrayref(
        "SELECT data from " . $self->{dbiTable} . " WHERE cfgNum=?",
        {}, $cfgNum );
    unless ($row) {
        $self->logError;
        return 0;
    }
    my $r;
    eval { $r = Storable::thaw( $row->[0] ); };
    if ($@) {
        $Lemonldap::NG::Common::Conf::msg .=
          "Bad stored data in conf database: $@ \n";
        return 0;
    }
    return $r;
}

1;
__END__
