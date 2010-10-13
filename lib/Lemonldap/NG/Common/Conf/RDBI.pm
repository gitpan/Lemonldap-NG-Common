package Lemonldap::NG::Common::Conf::RDBI;

use strict;
use Lemonldap::NG::Common::Conf::Serializer;
use Lemonldap::NG::Common::Conf::_DBI;

our $VERSION = '0.99';
our @ISA     = qw(Lemonldap::NG::Common::Conf::_DBI);

sub store {
    my ( $self, $fields ) = @_;
    $self->{noQuotes} = 1;
    $fields = $self->serialize($fields);
    my $errors = 0;
    eval { $self->_dbh->do('BEGIN'); };
    while ( my ( $k, $v ) = each %$fields ) {
        unless (
            $self->_dbh->do(
                    "insert into "
                  . $self->{dbiTable}
                  . " (cfgNum,field,value) values ("
                  . join( ',', $fields->{cfgNum}, "'$k'", "'$v'" ) . ')'
            )
          )
        {
            $self->logError;
            $errors++;
            last;
        }
    }
    eval { $errors ? $self->_dbh->do("ROLLBACK") : $self->_dbh->do("COMMIT"); };
    unless ( $self->unlock ) {
        $self->logError;
    }
    return $errors ? UNKNOWN_ERROR : $fields->{cfgNum};
}

sub load {
    my ( $self, $cfgNum, $fields ) = @_;
    $fields = $fields ? join( ",", @$fields ) : '*';
    my $sth =
      $self->_dbh->prepare( "SELECT cfgNum,field,value from "
          . $self->{dbiTable}
          . " WHERE cfgNum=$cfgNum" );
    $sth->execute();
    my ( $res, @row );
    while ( @row = $sth->fetchrow_array ) {
        $res->{ $row[1] } = $row[2];
    }
    unless ($res) {
        $Lemonldap::NG::Common::Conf::msg .= "No configuration $cfgNum found";
        return 0;
    }
    $res->{cfgNum} = $cfgNum;
    return $self->unserialize($res);
}

1;
__END__
