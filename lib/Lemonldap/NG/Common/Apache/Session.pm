package Lemonldap::NG::Common::Apache::Session;

use Storable qw(thaw);

BEGIN {

    sub Apache::Session::get_key_from_all_sessions {
        return 0;
    }

    sub Apache::Session::MySQL::get_key_from_all_sessions {
        my $class = shift;
        my $args  = shift;
        my $data  = shift;

        my $dbh =
          DBI->connect( $args->{DataSource}, $args->{UserName},
            $args->{Password} )
          or die("$!$@");
        my $sth = $dbh->prepare('SELECT id,a_session from sessions');
        $sth->execute;
        my %res;
        while ( my @row = $sth->fetchrow_array ) {
            if ( ref($data) eq 'CODE' ) {
                my $tmp = &$data( thaw( $row[1] ), $row[0] );
                $res{ $row[0] } = $tmp if ( defined($tmp) );
            }
            elsif ($data) {
                $data = [$data] unless ( ref($data) );
                my $tmp = thaw( $row[1] );
                $res{ $row[0] }->{$_} = $tmp->{$_} foreach (@$data);
            }
            else {
                $res{ $row[0] } = thaw( $row[1] );
            }
        }
        return \%res;
    }

    *Apache::Session::Postgres::get_key_from_all_sessions =
      \&Apache::Session::MySQL::get_key_from_all_sessions;
    *Apache::Session::Oracle::get_key_from_all_sessions =
      \&Apache::Session::MySQL::get_key_from_all_sessions;
    *Apache::Session::Sybase::get_key_from_all_sessions =
      \&Apache::Session::MySQL::get_key_from_all_sessions;
    *Apache::Session::Informix::get_key_from_all_sessions =
      \&Apache::Session::MySQL::get_key_from_all_sessions;

    sub Apache::Session::File::get_key_from_all_sessions {
        my $class = shift;
        my $args  = shift;
        my $data  = shift;
        $args->{Directory} ||= '/tmp';

        unless ( opendir DIR, $args->{Directory} ) {
            die "Cannot open directory $args->{Directory}\n";
        }
        my @t =
          grep { -f "$args->{Directory}/$_" and /^[A-Za-z0-9@\-]+$/ }
          readdir(DIR);
        closedir DIR;
        my %res;
        for my $f (@t) {
            open F, "$args->{Directory}/$f";
            my $row = join '', <F>;
            if ( ref($data) eq 'CODE' ) {
                $res{$f} = &$data( thaw($row), $f );
            }
            elsif ($data) {
                $data = [$data] unless ( ref($data) );
                my $tmp = thaw($row);
                $res{$f}->{$_} = $tmp->{$_} foreach (@$data);
            }
            else {
                $res{$f} = thaw($row);
            }
        }
        return \%res;
    }

    sub Apache::Session::PHP::get_key_from_all_sessions {
        require Apache::Session::Serialize::PHP;
        my $class = shift;
        my $args  = shift;

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
                $res{$f} = &$data( Apache::Session::Serialize::PHP::unserialize($row), $f );
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

    sub Apache::Session::DB_File::get_key_from_all_sessions {
        my $class = shift;
        my $args  = shift;

        if ( !tied %{ $class->{dbm} } ) {
            my $rv = tie %{ $class->{dbm} }, 'DB_File', $args->{FileName};
            if ( !$rv ) {
                die "Could not open dbm file " . $args->{FileName} . ": $!";
            }
        }

        my %res;
        foreach my $k ( keys %{ $class->{dbm} } ) {
            if ( ref($data) eq 'CODE' ) {
                $res{$k} = &$data( thaw( $class->{dbm}->{$k} ), $k );
            }
            elsif ($data) {
                $data = [$data] unless ( ref($data) );
                my $tmp = thaw( $class->{dbm}->{$k} );
                $res{$k}->{$_} = $tmp->{$_} foreach (@$data);
            }
            else {
                $res{$k} = thaw( $class->{dbm}->{$k} );
            }
        }
    }

    sub Apache::Session::Memcached::get_key_from_all_sessions {

        # TODO
        die ('Apache::Session::Memcached is not supported by Lemonldap::NG');
    }
}

1;
