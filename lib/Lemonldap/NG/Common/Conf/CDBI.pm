package Lemonldap::NG::Common::Conf::CDBI;

use strict;
require Storable;
use Lemonldap::NG::Common::Conf::_DBI;

our $VERSION = '1.1.0';
our @ISA     = qw(Lemonldap::NG::Common::Conf::_DBI);

sub store {
    my ( $self, $fields ) = @_;
    my $cfgNum = $fields->{cfgNum};
    $fields = Storable::nfreeze($fields);
    my $tmp = $self->_dbh->prepare(
        "insert into $self->{dbiTable} (cfgNum,data) values (?,?)");
    unless ($tmp) {
        $self->logError;
        return UNKNOWN_ERROR;
    }
    unless ( $tmp->execute( $cfgNum, $fields ) ) {
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
        "SELECT data from " . $self->{dbiTable} . " WHERE cfgNum=$cfgNum" );
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
