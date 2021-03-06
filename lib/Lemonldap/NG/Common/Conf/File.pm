package Lemonldap::NG::Common::Conf::File;

use strict;
use Lemonldap::NG::Common::Conf::Constants;    #inherits
use Lemonldap::NG::Common::Conf::Serializer;

our $VERSION = '1.4.0';

sub prereq {
    my $self = shift;
    unless ( $self->{dirName} ) {
        $Lemonldap::NG::Common::Conf::msg .=
          '"dirName" is required in "File" configuration type ! \n';
        return 0;
    }
    unless ( -d $self->{dirName} ) {
        $Lemonldap::NG::Common::Conf::msg .=
          "Directory \"$self->{dirName}\" does not exist ! \n";
        return 0;
    }
    1;
}

sub available {
    my $self = shift;
    opendir D, $self->{dirName};
    my @conf = readdir(D);
    closedir D;
    @conf = sort { $a <=> $b } map { /lmConf-(\d+)/ ? $1 : () } @conf;
    return @conf;
}

sub lastCfg {
    my $self  = shift;
    my @avail = $self->available;
    return $avail[$#avail];
}

sub lock {
    my $self = shift;
    if ( $self->isLocked ) {
        sleep 2;
        return 0 if ( $self->isLocked );
    }
    unless ( open F, ">" . $self->{dirName} . "/lmConf.lock" ) {
        $Lemonldap::NG::Common::Conf::msg .=
          "Unable to lock (" . $self->{dirName} . "/lmConf.lock) \n";
        return 0;
    }
    print F $$;
    close F;
    return 1;
}

sub isLocked {
    my $self = shift;
    -e $self->{dirName} . "/lmConf.lock";
}

sub unlock {
    my $self = shift;
    unlink $self->{dirName} . "/lmConf.lock";
    1;
}

sub store {
    my ( $self, $fields ) = @_;
    $fields = $self->serialize($fields);
    my $mask = umask;
    umask( oct('0027') );
    unless ( open FILE,
        '>' . $self->{dirName} . "/lmConf-" . $fields->{cfgNum} )
    {
        $Lemonldap::NG::Common::Conf::msg .= "Open file failed: $! \n";
        $self->unlock;
        return UNKNOWN_ERROR;
    }
    foreach my $k ( sort keys %$fields ) {
        print FILE "$k\n\t$fields->{$k}\n\n";
    }
    close FILE;
    umask($mask);
    return $fields->{cfgNum};
}

sub load {
    my ( $self, $cfgNum, $fields ) = @_;
    my $f;
    local $/ = "";
    open FILE, $self->{dirName} . "/lmConf-$cfgNum";
    while (<FILE>) {
        my ( $k, $v ) = split /\n\s+/;
        chomp $k;
        $v =~ s/\n*$//;
        if ($fields) {
            $f->{$k} = $v if ( grep { $_ eq $k } @$fields );
        }
        else {
            $f->{$k} = $v;
        }
    }
    close FILE;
    return $self->unserialize($f);
}

sub delete {
    my ( $self, $cfgNum ) = @_;
    unlink( $self->{dirName} . "/lmConf-$cfgNum" );
}

1;
__END__
