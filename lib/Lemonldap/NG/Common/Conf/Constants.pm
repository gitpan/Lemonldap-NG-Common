package Lemonldap::NG::Common::Conf::Constants;

use strict;
use Exporter 'import';

use base qw(Exporter);
our $VERSION = '0.991';

# CONSTANTS

use constant CONFIG_WAS_CHANGED => -1;
use constant UNKNOWN_ERROR      => -2;
use constant DATABASE_LOCKED    => -3;
use constant UPLOAD_DENIED      => -4;
use constant SYNTAX_ERROR       => -5;
use constant DEPRECATED         => -6;
use constant DEFAULTCONFFILE => "/usr/local/lemonldap-ng/etc/lemonldap-ng.ini";
use constant DEFAULTSECTION  => "all";
use constant CONFSECTION     => "configuration";
use constant PORTALSECTION   => "portal";
use constant HANDLERSECTION  => "handler";
use constant MANAGERSECTION  => "manager";
use constant APPLYSECTION    => "apply";

our %EXPORT_TAGS = (
    'all' => [
        qw(
          CONFIG_WAS_CHANGED
          UNKNOWN_ERROR
          DATABASE_LOCKED
          UPLOAD_DENIED
          SYNTAX_ERROR
          DEPRECATED
          DEFAULTCONFFILE
          DEFAULTSECTION
          CONFSECTION
          PORTALSECTION
          HANDLERSECTION
          MANAGERSECTION
          APPLYSECTION
          )
    ]
);

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = ( @{ $EXPORT_TAGS{'all'} } );

1;
__END__
