# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Lemonldap-NG-Common.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 19;
use strict;

BEGIN {
    use_ok('Lemonldap::NG::Common::Crypto');
}

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $c;

ok(
    $c = Lemonldap::NG::Common::Crypto->new(
        'lemonldap-ng-key', Crypt::Rijndael::MODE_CBC()
    ),
    'New object'
);
foreach my $i ( 1 .. 17 ) {
    my $s = '';
    $s = join( '', map { chr( int( rand(94) ) + 33 ) } ( 1 .. $i ) );
    ok( $c->decrypt( $c->encrypt($s) ) eq $s,
        "Test with $i characters string" );
}

