##@file
# Functions shared in Safe jail

##@class
# Functions shared in Safe jail
package Lemonldap::NG::Common::Safelib;

use strict;
use Encode;
use MIME::Base64;

#use AutoLoader qw(AUTOLOAD);

our $VERSION = '1.2.2_01';

# Set here all the names of functions that must be available in Safe objects.
# Not that only functions, not methods, can be written here
our $functions =
  [qw(&checkLogonHours &checkDate &basic &unicode2iso &iso2unicode)];

## @function boolean checkLogonHours(string logon_hours, string syntax, string time_correction, boolean default_access)
# Function to check logon hours
# @param $logon_hours string representing allowed logon hours (GMT)
# @param $syntax optional hexadecimal (default) or octetstring
# @param $time_correction optional hours to add or to subtract
# @param $default_access optional what result to return for users without logons hours
# @return 1 if access allowed, 0 else
sub checkLogonHours {
    my ( $logon_hours, $syntax, $time_correction, $default_access ) = splice @_;

    # Active Directory - logonHours: $attr_src_syntax = octetstring
    # Samba - sambaLogonHours: ???
    # LL::NG - ssoLogonHours: $attr_src_syntax = hexadecimal
    $syntax ||= "hexadecimal";

    # Default access if no value
    $default_access ||= "0";
    return $default_access unless $logon_hours;

    # Get the base2 value of logon_hours
    # Each byte represent an hour of the week
    # Begin with sunday at 0h00
    my $base2_logon_hours;
    if ( $syntax eq "octetstring" ) {
        $base2_logon_hours = unpack( "B*", $logon_hours );
    }
    if ( $syntax eq "hexadecimal" ) {

        # Remove white spaces
        $logon_hours =~ s/ //g;
        $base2_logon_hours = unpack( "B*", pack( "H*", $logon_hours ) );
    }

    # Get the present day and hour
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
      gmtime(time);

    # Get the hour position
    my $hourpos = $wday * 24 + $hour;

    # Use time_correction
    if ($time_correction) {
        my ( $sign, $time ) = ( $time_correction =~ /([+|-]?)(\d+)/ );
        if ( $sign =~ /-/ ) { $hourpos -= $time; }
        else                { $hourpos += $time; }
    }

    # Get the corresponding byte
    return substr( $base2_logon_hours, $hourpos, 1 );
}

## @function boolean checkDate(string start, string end, boolean default_access)
# Function to check a date
# @param $start string Start date (GMT)
# @param $end string End date (GMT)
# @param $default_access optional what result to return for users without start or end start
# @return 1 if access allowed, 0 else
sub checkDate {
    my ( $start, $end, $default_access ) = splice @_;

    # Get date in string
    $start = substr( $start, 0, 14 );
    $end   = substr( $end,   0, 14 );

    # Default access if no value
    $default_access ||= "0";
    return $default_access unless ( $start or $end );

    # If no start, set start to 0
    $start ||= 0;

    # If no end, set end to the end of the world
    $end ||= 999999999999999;

    # Get the present day and hour
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
      gmtime(time);
    $year += 1900;
    $mon  += 1;
    $mon  = "0" . $mon  if ( $mon < 10 );
    $mday = "0" . $mday if ( $mday < 10 );
    $hour = "0" . $hour if ( $hour < 10 );
    $min  = "0" . $min  if ( $min < 10 );
    $sec  = "0" . $sec  if ( $sec < 10 );

    my $date = $year . $mon . $mday . $hour . $min . $sec;

    return 1 if ( ( $date >= $start ) and ( $date <= $end ) );
    return 0;
}

## @function string basic(string login, string password)
# Return string that can be used for HTTP-BASIC authentication
# @param login User login
# @param password User password
# @return Authorization header content
sub basic {
    my ( $login, $password ) = splice @_;

    # UTF-8 strings should be ISO encoded
    $login    = &unicode2iso($login);
    $password = &unicode2iso($password);

    return "Basic " . encode_base64( $login . ":" . $password );
}

## @function string unicode2iso(string string)
# Convert UTF-8 in ISO-8859-1
# @param string UTF-8 string
# @return ISO string
sub unicode2iso {
    my ($string) = splice @_;

    return encode( "iso-8859-1", decode( "utf-8", $string ) );
}

## @function string iso2unicode(string string)
# Convert ISO-8859-1 in UTF-8
# @param string ISO string
# @return UTF-8 string
sub iso2unicode {
    my ($string) = splice @_;

    return encode( "utf-8", decode( "iso-8859-1", $string ) );
}

1;
__END__

=head1 NAME

=encoding utf8

Lemonldap::NG::Common::Safelib - Contains functions that are automatically
imported in Lemonldap::NG Safe objects to be used in expressions like rules,
macros,...

=head1 SYNOPSIS

Private module not documented.

=head1 DESCRIPTION

Private module not documented.

=head1 SEE ALSO

L<Lemonldap::NG::Manager>, L<Lemonldap::NG::Portal>, L<Lemonldap::NG::Handler>

=head1 AUTHOR

Xavier Guimard, E<lt>x.guimard@free.frE<gt>
Clement Oudot

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009, 2010 by Xavier Guimard

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut

