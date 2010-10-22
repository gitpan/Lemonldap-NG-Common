package Lemonldap::NG::Common::Conf::CDBI;

use strict;
require Storable;
use Lemonldap::NG::Common::Conf::_DBI;

our $VERSION = '0.991';
our @ISA     = qw(Lemonldap::NG::Common::Conf::_DBI);

sub store {
    my ( $self, $fields ) = @_;
    my $cfgNum = $fields->{cfgNum};
    $fields = Storable::nfreeze($fields);
    $fields =~ s/'/''/gs;
    my $tmp =
      $self->_dbh->do( "insert into "
          . $self->{dbiTable}
          . " (cfgNum,data) values ($cfgNum,'$fields')" );
    unless ($tmp) {
        $self->logError;
        return UNKNOWN_ERROR;
    }
    unless ( $self->unlock ) {
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
    eval { $r = Storable::thaw( $row->[1] ); };
    if ($@) {
        $Lemonldap::NG::Common::Conf::msg =
          "Bad stored data in conf database: $@";
        return 0;
    }
    return $r;
}

1;
__END__
