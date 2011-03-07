## @file
# LL::NG module for Safe jail

## @package
# LL::NG module for Safe jail
package Lemonldap::NG::Common::Safe;

use strict;
use base qw(Safe);
use constant SAFEWRAP => ( Safe->can("wrap_code_ref") ? 1 : 0 );

our $VERSION = 1.0.3;

our $self;    # Safe cannot share a variable declared with my

## @constructor Lemonldap::NG::Common::Safe new(Lemonldap::NG::Portal::Simple portal)
# Build a new Safe object
# @param portal Lemonldap::NG::Portal::Simple object
# @return Lemonldap::NG::Common::Safe object
sub new {
    my ( $class, $portal ) = splice @_;
    my $self = {};

    unless ( $portal->{useSafeJail} ) {

        # Fake jail
        $portal->lmLog( "Creating a fake Safe jail", 'debug' );
        bless $self, $class;
    }
    else {

        # Safe jail
        $self = $class->SUPER::new();
        $portal->lmLog( "Creating a real Safe jail", 'debug' );
    }

    # Store portal object
    $self->{p} = $portal;

    return $self;
}

## @method reval(string $e)
# Evaluate an expression, inside or outside jail
# @param e Expression to evaluate
sub reval {
    local $self = shift;
    my ($e) = splice @_;
    my $result;

    # Replace $date
    $e =~ s/\$date/&POSIX::strftime("%Y%m%d%H%M%S",localtime())/e;

    # Replace variables by session content
    # Manage subroutine not the same way as plain perl expressions
    if ( $e =~ /^sub\s*{/ ) {
        $e =~ s/\$(?!ENV)(?!self)(\w+)/\$self->{sessionInfo}->{$1}/g;
    }
    else {
        $e =~ s/\$(?!ENV)(\w+)/\$self->{p}->{sessionInfo}->{$1}/g;
    }

    $self->{p}->lmLog( "Evaluate expression: $e", 'debug' );

    if ( $self->{p}->{useSafeJail} ) {

        # Share $self to access sessionInfo HASH
        $self->SUPER::share('$self');

        # Test SAFEWRAP and run reval
        $result = (
            ( SAFEWRAP and ref($e) eq 'CODE' )
            ? $self->SUPER::wrap_code_ref( $self->SUPER::reval($e) )
            : $self->SUPER::reval($e)
        );
    }
    else {

        # Use a standard eval
        $result = eval $e;
    }

    $self->{p}->lmLog( "Evaluation result: $result", 'debug' );

    return $result;
}

1;
