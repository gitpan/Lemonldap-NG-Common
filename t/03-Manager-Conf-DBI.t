# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Lemonldap-NG-Manager.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 3;
BEGIN { use_ok('Lemonldap::NG::Common::Conf') }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $h;
@ARGV = ("help=groups");
ok(
    $h = new Lemonldap::NG::Common::Conf(
    {
	    type     => 'DBI',
	    dbiChain => "DBI:mysql:database=lemonldap-ng",
	    dbiUser  => 'lemonldap-ng',
	}
    )
);

ok( $h->can( 'dbh' ) ); 
