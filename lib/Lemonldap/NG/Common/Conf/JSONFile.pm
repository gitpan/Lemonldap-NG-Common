package Lemonldap::NG::Common::Conf::JSONFile;

use strict;
use Lemonldap::NG::Common::Conf::Constants;    #inherits

our $VERSION = '1.4.0';
our $initDone;

sub prereq {
    my $self = shift;
    unless ($initDone) {
        eval "use JSON::Any";
        if ($@) {
            $Lemonldap::NG::Common::Conf::msg .=
              "Unable to load JSON::Any: $@\n";
            return 0;
        }
        $initDone++;
    }
    unless ( $self->{dirName} ) {
        $Lemonldap::NG::Common::Conf::msg .=
          '"dirName" is required in "JSONFile" configuration type ! \n';
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
    @conf = sort { $a <=> $b } map { /lmConf-(\d+)\.js/ ? $1 : () } @conf;
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
    my $mask = umask;
    umask( oct('0027') );
    unless ( open FILE, ">$self->{dirName}/lmConf-$fields->{cfgNum}.js" ) {
        $Lemonldap::NG::Common::Conf::msg .= "Open file failed: $! \n";
        $self->unlock;
        return UNKNOWN_ERROR;
    }
    print FILE JSON::Any->objToJson($fields);
    close FILE;
    umask($mask);
    return $fields->{cfgNum};
}

sub load {
    my ( $self, $cfgNum, $fields ) = @_;
    my $f = '';
    open FILE, "$self->{dirName}/lmConf-$cfgNum.js" or die "$!$@";
    while (<FILE>) {
        $f .= $_;
    }
    close FILE;
    my $ret;
    eval { $ret = JSON::Any->jsonToObj($f); };
    die "Unable to load conf: $@\n" if ($@);
    return $ret;
}

sub delete {
    my ( $self, $cfgNum ) = @_;
    unlink( $self->{dirName} . "/lmConf-$cfgNum.js" );
}

1;
__END__
