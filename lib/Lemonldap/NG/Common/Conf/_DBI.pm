package Lemonldap::NG::Common::Conf::_DBI;

use strict;
use DBI;
use Lemonldap::NG::Common::Conf::Constants;    #inherits

our $VERSION = '0.991';
our @ISA     = qw(Lemonldap::NG::Common::Conf::Constants);
our ( @EXPORT, %EXPORT_TAGS );

BEGIN {
    *Lemonldap::NG::Common::Conf::_dbh = \&_dbh;
    *EXPORT      = \@Lemonldap::NG::Common::Conf::Constants::EXPORT;
    *EXPORT_TAGS = \%Lemonldap::NG::Common::Conf::Constants::EXPORT_TAGS;
    push @EXPORT,
      qw(prereq available lastCfg _dbh lock isLocked unlock delete logError);
}

sub prereq {
    my $self = shift;
    unless ( $self->{dbiChain} ) {
        $Lemonldap::NG::Common::Conf::msg =
          '"dbiChain" is required in *DBI configuration type';
        return 0;
    }
    print STDERR __PACKAGE__ . 'Warning: "dbiUser" parameter is not set'
      unless ( $self->{dbiUser} );
    $self->{dbiTable} ||= "lmConfig";
    1;
}

sub available {
    my $self = shift;
    my $sth =
      $self->_dbh->prepare( "SELECT DISTINCT cfgNum from "
          . $self->{dbiTable}
          . " order by cfgNum" );
    $sth->execute();
    my @conf;
    while ( my @row = $sth->fetchrow_array ) {
        push @conf, $row[0];
    }
    return @conf;
}

sub lastCfg {
    my $self = shift;
    my @row  = $self->_dbh->selectrow_array(
        "SELECT max(cfgNum) from " . $self->{dbiTable} );
    return $row[0];
}

sub _dbh {
    my $self = shift;
    $self->{dbiTable} ||= "lmConfig";
    return $self->{_dbh} if ( $self->{_dbh} and $self->{_dbh}->ping );
    return DBI->connect_cached( $self->{dbiChain}, $self->{dbiUser},
        $self->{dbiPassword}, { RaiseError => 1, AutoCommit => 1, } );
}

sub lock {
    my $self = shift;
    my $sth;
    if ( $self->{dbiChain} =~ /mysql/i ) {
        eval {
            $sth =
              $self->dbh->prepare_cached( q{SELECT GET_LOCK(?, 5)}, {}, 1 );
            $sth->execute('lmconf');
            my @row = $sth->fetchrow_array;
            return $row[0] || 0;
        };
    }
    else {

        # TODO
        return 1;
    }
}

sub isLocked {
    my $self = shift;
    my $sth;
    if ( $self->{dbiChain} =~ /mysql/i ) {
        eval {
            $sth =
              $self->_dbh->prepare_cached( q{SELECT IS_FREE_LOCK(?)}, {}, 1 );
            $sth->execute('lmconf');
            my @row = $sth->fetchrow_array;
            return $row[0] ? 0 : 1;
        };
    }
    else {

        # TODO
        return 0;
    }
}

sub unlock {
    my $self = shift;
    my $sth;
    if ( $self->{dbiChain} =~ /mysql/i ) {
        eval {
            $sth =
              $self->_dbh->prepare_cached( q{SELECT RELEASE_LOCK(?)}, {}, 1 );
            $sth->execute('lmconf');
            my @row = $sth->fetchrow_array;
            return $row[0] || 0;
        };
    }
    else {

        # TODO
        return 1;
    }
}

sub delete {
    my ( $self, $cfgNum ) = @_;
    $self->_dbh->do(
        "DELETE from " . $self->{dbiTable} . " WHERE cfgNum=$cfgNum" );
}

sub logError {
    my $self = shift;
    $Lemonldap::NG::Common::Conf::msg .=
      "Database error: " . $self->_dbh->errstr . "\n";
}

1;
__END__
