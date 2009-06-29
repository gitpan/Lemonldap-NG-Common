##@file
# Base package for Lemonldap::NG configuration system

##@class
# Implements Lemonldap::NG shared configuration system.
# In case of error or warning, the message is stored in the global variable
# $Lemonldap::NG::Common::Conf::msg
package Lemonldap::NG::Common::Conf;

use strict;
no strict 'refs';
use Data::Dumper;
use Lemonldap::NG::Common::Conf::Constants; #inherits
use Lemonldap::NG::Common::Crypto; #link protected cipher Object "cypher" in configuration hash
use Regexp::Assemble;

#inherits Lemonldap::NG::Common::Conf::File
#inherits Lemonldap::NG::Common::Conf::DBI
#inherits Lemonldap::NG::Common::Conf::SOAP
#inherits Lemonldap::NG::Common::Conf::LDAP

use constant DEFAULTCONFFILE => "/etc/lemonldap-ng/storage.conf";

our $VERSION = 0.6;
our $msg;

our %_confFiles;

## @cmethod Lemonldap::NG::Common::Conf new(hashRef arg)
# Constructor.
# Succeed if it has found a way to access to Lemonldap::NG configuration with
# $arg (or default file). It can be :
# - Nothing: default configuration file is tested, 
# - { confFile => "/path/to/storage.conf" },
# - { Type => "File", dirName => "/path/to/conf/dir/" },
# - { Type => "DBI", dbiChain => "DBI:mysql:database=lemonldap-ng;host=1.2.3.4",
# dbiUser => "user", dbiPassword => "password" },
# - { Type => "SOAP", proxy => "https://auth.example.com/index.pl/config" },
# - { Type => "LDAP", ldapServer => "ldap://localhost", ldapConfBranch => "ou=conf,ou=applications,dc=example,dc=com",
#  ldapBindDN => "cn=manager,dc=example,dc=com", ldapBindPassword => "secret"},
#
# $self->{type} contains the type of configuration access system and the
# corresponding package is loaded.
# @param $arg hash reference or hash table
# @return New Lemonldap::NG::Common::Conf object
sub new {
    my $class = shift;
    my $self = bless {}, $class;
    if ( ref( $_[0] ) ) {
        %$self = %{ $_[0] };
    }
    else {
        %$self = @_;
    }
    unless ( $self->{mdone} ) {
        $self->_readConfFile( $self->{confFile} ) unless ( $self->{type} );
        unless ( $self->{type} ) {
            $msg .= "Error: configStorage: type is not defined\n";
            return 0;
        }
        $self->{type} = "Lemonldap::NG::Common::Conf::$self->{type}"
          unless $self->{type} =~ /^Lemonldap::/;
        eval "require $self->{type}";
        if ($@) {
            $msg .= "Error: Unknown package $self->{type}";
            return 0;
        }
        return 0 unless $self->prereq;
        $self->{mdone}++;
        $msg = "$self->{type} loaded";
    }
    if ( $self->{localStorage} and not defined( $self->{refLocalStorage} ) ) {
        eval "use $self->{localStorage};";
        if ($@) {
            $msg .= "Unable to load $self->{localStorage}: $@";
        }
        else {
            $self->{refLocalStorage} =
              $self->{localStorage}->new( $self->{localStorageOptions} );
        }
    }
    return $self;
}

## @method private boolean _readConfFile(string file)
# Read $file to know how to access to Lemonldap::NG configuration.
# @param $file Optional file name (default: /etc/lemonldap-ng/storage.conf)
# @return True if the file was successfuly read
sub _readConfFile {
    my $self = shift;
    my $file = shift || DEFAULTCONFFILE;
    unless ( $_confFiles{$file} ) {
        unless ( open F, $file ) {
            $msg = "Warning $file: $!. ";
            return 0;
        }
        while (<F>) {
            next if ( /^\s*$/ or /^\s*#/ );
            chomp;
            s/\r//g;
            /^\s*([\w]+)(?:\s*[:=]\s*|\s+)(["']?)([\S].*[\S])\2\s*$/ or next;
            my $k = $1;
            $_confFiles{$file}->{$k} = $3;
            if ( $_confFiles{$file}->{$k} =~ /^[{\[].*[}\]]$/ ) {
                eval "\$_confFiles{'$file'}->{'$k'} = $_confFiles{$file}->{$k}";
                if ($@) {
                    $msg = "Warning: error in file $file : $@. ";
                    return 0;
                }
            }
        }
        close F;
    }
    %$self = ( %$self, %{ $_confFiles{$file} } );
    return 1;
}

## @method int saveConf(hashRef conf)
# Serialize $conf and call store().
# @param $conf Lemonldap::NG configuration hashRef
# @return Number of the saved configuration, 0 if case of error.
sub saveConf {
    my ( $self, $conf ) = @_;

    # If configuration was modified, return an error
    return CONFIG_WAS_CHANGED
      if ( $conf->{cfgNum} != $self->lastCfg or $self->isLocked );
    $self->lock or return DATABASE_LOCKED;
    my $fields;
    local $Data::Dumper::Indent = 0;
    local $Data::Dumper::Varname = "data";
    while ( my ( $k, $v ) = each(%$conf) ) {
        next if ( $k =~ /^(?:reVHosts|cipher)$/ );
        if ( ref($v) ) {
            $fields->{$k} = Dumper($v);
            $fields->{$k} =~ s/'/&#39;/g;
            $fields->{$k} = "'$fields->{$k}'";
        }
        elsif ( $v =~ /^\d+$/ ) {
            $fields->{$k} = "$v";
        }
        else {

            # mono-line
            $v =~ s/[\r\n]/ /gm;

            # trim
            $v =~ s/^\s*(.*?)\s*$/$1/;
            $fields->{$k} = "'$v'";
        }
    }
    $fields->{cfgNum} = $self->lastCfg + 1;
    $msg = "Configuration $fields->{cfgNum} stored";
    return $self->store($fields);
}

## @method hashRef getConf(hashRef args)
# Get configuration from remote configuration storage system or from local
# cache if configuration has not been changed. If $args->{local} is set and if
# a local configuration is available, remote configuration is not tested.
#
# Uses lastCfg to test and getDBConf() to get the remote configuration
# @param $args Optional, contains {local=>1} or nothing
# @return Lemonldap::NG configuration
sub getConf {
    my ( $self, $args ) = @_;
    if (    $args->{'local'}
        and ref( $self->{refLocalStorage} )
        and my $res = $self->{refLocalStorage}->get('conf') )
    {
        $msg = "get configuration from cache without verification";
        return $res;
    }
    else {
        $args->{cfgNum} ||= $self->lastCfg;
        unless ( $args->{cfgNum} ) {
            $msg = "No configuration available";
            return 0;
        }
        my $r;
        unless ( ref( $self->{refLocalStorage} ) ) {
            $msg = "get remote configuration (localStorage unavailable)";
            $r   = $self->getDBConf($args);
        }
        else {
            $r = $self->{refLocalStorage}->get('conf');
        if ( $r->{cfgNum} == $args->{cfgNum} ) {
            $msg = "configuration unchanged, get configuration from cache";
        }
            else {
                $r = $self->getDBConf($args);
            }
        }
        if ( $args->{clean} ) {
            delete $r->{reVHosts};
        }
        else {
            eval {
                $r->{cipher} = Lemonldap::NG::Common::Crypto->new(
                    $r->{key} || 'lemonldap-ng-key',
                    Crypt::Rijndael::MODE_CBC()
                );
            };
            if ($@) {
                $msg = "Bad key : $@";
                return 0;
            }
        }
        return $r;
    }
}

## @method void setLocalConf(hashRef conf)
# Store $conf in the local cache.
# @param $conf Lemonldap::NG configuration hashRef
sub setLocalConf {
    my ( $self, $conf ) = @_;
    $self->{refLocalStorage}->set( "conf", $conf );
}

## @method hashRef getDBConf(hashRef args)
# Get configuration from remote storage system.
# @param $args hashRef that must contains a key "cfgNum" (number of the wanted
# configuration) and optionaly a key "fields" that points to an array of wanted
# configuration keys
# @return Lemonldap::NG configuration hashRef
sub getDBConf {
    my ( $self, $args ) = @_;
    return undef unless $args->{cfgNum};
    if ( $args->{cfgNum} < 0 ) {
        my @a = $self->available();
        $args->{cfgNum} =
            ( @a + $args->{cfgNum} > 0 )
          ? ( $a[ $#a + $args->{cfgNum} ] )
          : $a[0];
    }
    my $fields = $self->load( $args->{cfgNum} );
    my $conf;
    while ( my ( $k, $v ) = each(%$fields) ) {
        $v =~ s/^'(.*)'$/$1/s;
        if ( $k =~
/^(?:exportedVars|locationRules|groups|exportedHeaders|macros|globalStorageOptions)$/
            and $v ||= {}
            and not ref($v) )
        {
            $conf->{$k} = {};
            if ( defined($v) and $v !~ /^\$/ ) {
                print STDERR
"Lemonldap::NG : Warning: configuration is in old format, you've to migrate !\n";
                eval { require Storable; require MIME::Base64; };
                if ($@) {
                    $msg = "Error : $@";
                    return 0;
                }
                $conf->{$k} = Storable::thaw( MIME::Base64::decode_base64($v) );
            }
            else {
                my $data;
                $v =~ s/^\$([_a-zA-Z][_a-zA-Z0-9]*) *=/\$data =/;
                $v =~ s/&#?39;/'/g;
                eval $v;
                print STDERR
"Lemonldap::NG : Error while reading configuration with $k key: $@\n"
                  if ($@);
                $conf->{$k} = $data;
            }
        }
        else {
            $conf->{$k} = $v;
        }
    }
    $msg = "Get configuration $conf->{cfgNum}";
    my $re = Regexp::Assemble->new();
    foreach ( keys %{ $conf->{locationRules} } ) {
        $_ = quotemeta($_);
        $re->add($_);
    }
    $conf->{reVHosts} = $re->as_string;
    $self->setLocalConf($conf)
      if ( $self->{refLocalStorage} and not( $args->{noCache} ) );
    return $conf;
}

## @method boolean prereq()
# Call prereq() from the $self->{type} package.
# @return True if succeed
sub prereq {
    return &{ $_[0]->{type} . '::prereq' }(@_);
}

## @method @ available()
# Call available() from the $self->{type} package.
# @return list of available configuration numbers
sub available {
    return &{ $_[0]->{type} . '::available' }(@_);
}

## @method int lastCfg()
# Call lastCfg() from the $self->{type} package.
# @return Number of the last configuration available
sub lastCfg {
    return &{ $_[0]->{type} . '::lastCfg' }(@_);
}

## @method boolean lock()
# Call lock() from the $self->{type} package.
# @return True if succeed
sub lock {
    return &{ $_[0]->{type} . '::lock' }(@_);
}

## @method boolean isLocked()
# Call isLocked() from the $self->{type} package.
# @return True if database is locked
sub isLocked {
    return &{ $_[0]->{type} . '::isLocked' }(@_);
}

## @method boolean unlock()
# Call unlock() from the $self->{type} package.
# @return True if succeed
sub unlock {
    return &{ $_[0]->{type} . '::unlock' }(@_);
}

## @method int store(hashRef conf)
# Call store() from the $self->{type} package.
# @param $conf Lemondlap configuration serialized
# @return Number of new configuration stored if succeed, 0 else.
sub store {
    return &{ $_[0]->{type} . '::store' }(@_);
}

## @method load(int cfgNum, arrayRef fields)
# Call load() from the $self->{type} package.
# @return Lemonldap::NG Configuration hashRef if succeed, 0 else.
sub load {
    return &{ $_[0]->{type} . '::load' }(@_);
}

## @method boolean delete(int cfgNum)
# Call delete() from the $self->{type} package.
# @param $cfgNum Number of configuration to delete
# @return True if succeed
sub delete {
    my ( $self, $c ) = @_;
    my @a = $self->available();
    return 0 unless ( @a + $c > 0 );
    return &{ $self->{type} . '::delete' }( $self, $a[ $#a + $c ] );
}

1;
__END__

=head1 NAME

Lemonldap::NG::Common::Conf - Perl extension written to manage Lemonldap::NG
Web-SSO configuration.

=head1 SYNOPSIS

  use Lemonldap::NG::Common::Conf;
  my $confAccess = new Lemonldap::NG::Common::Conf(
              {
                  type=>'File',
                  dirName=>"/tmp/",

                  # To use local cache, set :
                  localStorage => "Cache::FileCache",
                  localStorageOptions = {
                      'namespace' => 'MyNamespace',
                      'default_expires_in' => 600,
                      'directory_umask' => '007',
                      'cache_root' => '/tmp',
                      'cache_depth' => 5,
                  },
              },
    ) or die "Unable to build Lemonldap::NG::Common::Conf, see Apache logs";
  my $config = $confAccess->getConf();

=head1 DESCRIPTION

Lemonldap::NG::Common::Conf provides a simple interface to access to
Lemonldap::NG Web-SSO configuration. It is used by L<Lemonldap::NG::Handler>,
L<Lemonldap::NG::Portal> and L<Lemonldap::NG::Manager>.

=head2 SUBROUTINES

=over

=item * B<new> (constructor): it takes different arguments depending on the
choosen type. Examples:

=over

=item * B<File>:
  $confAccess = new Lemonldap::NG::Common::Conf(
                {
                type    => 'File',
                dirName => '/var/lib/lemonldap-ng/',
                });

=item * B<DBI>:
  $confAccess = new Lemonldap::NG::Common::Conf(
                {
                type        => 'DBI',
                dbiChain    => 'DBI:mysql:database=lemonldap-ng;host=1.2.3.4',
                dbiUser     => 'lemonldap'
                dbiPassword => 'pass'
                dbiTable    => 'lmConfig',
                });

=item * B<SOAP>:
  $confAccess = new Lemonldap::NG::Common::Conf(
                {
                type         => 'SOAP',
                proxy        => 'http://auth.example.com/index.pl/config',
                proxyOptions => {
                                timeout => 5,
                                },
                });

SOAP configuration access is a sort of proxy: the portal is configured to use
the real session storage type (DBI or File for example). See HTML documentation
for more.

=item * B<LDAP>:
  $confAccess = new Lemonldap::NG::Common::Conf(
                {
                type             => 'LDAP',
                ldapServer       => 'ldap://localhost',
                ldapConfBranch   => 'ou=conf,ou=applications,dc=example,dc=com',
                ldapBindDN       => 'cn=manager,dc=example,dc=com",
                ldapBindPassword => 'secret'
                });

=back

WARNING: You have to use the same storage type on all Lemonldap::NG parts in
the same server.

=item * B<getConf>: returns a hash reference to the configuration. it takes
a hash reference as first argument containing 2 optional parameters:

=over

=item * C<cfgNum => $number>: the number of the configuration wanted. If this
argument is omitted, the last configuration is returned.

=item * C<fields => [array of names]: the desired fields asked. By default,
getConf returns all (C<select * from lmConfig>).

=back

=item * B<saveConf>: stores the Lemonldap::NG configuration passed in argument
(hash reference). it returns the number of the new configuration.

=back

=head1 SEE ALSO

L<Lemonldap::NG::Handler>, L<Lemonldap::NG::Portal>,
http://wiki.lemonldap.objectweb.org/xwiki/bin/view/NG/Presentation

=head1 AUTHOR

Xavier Guimard, E<lt>x.guimard@free.frE<gt>

=head1 BUG REPORT

Use OW2 system to report bug or ask for features:
L<http://forge.objectweb.org/tracker/?group_id=274>

=head1 DOWNLOAD

Lemonldap::NG is available at
L<http://forge.objectweb.org/project/showfiles.php?group_id=274>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006-2007 by Xavier Guimard

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
