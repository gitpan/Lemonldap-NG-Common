use 5.008;
use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

sub MY::top_targets {
    my $self = shift;
    my $r    = $self->MM::top_targets(@_);
    if ( my $cf = $ENV{LMNGCONFFILE} ) {
        $r =~ s/^(all.*)$/$1 my_target/m;
        $cf = quotemeta($cf);
        $r .= <<"EOT";

my_target:
	perl -i -pe 's/^(use constant DEFAULTCONFFILE\\s*=>).*\$\$/\$\$1 "$cf";/' blib/lib/Lemonldap/NG/Common/Conf/Constants.pm
EOT
    }
    return $r;
}

WriteMakefile(
    NAME           => 'Lemonldap::NG::Common',
    VERSION_FROM   => 'lib/Lemonldap/NG/Common.pm',    # finds $VERSION
    LICENSE        => 'perl',
    BUILD_REQUIRES => {
        'IO::String' => 0,
        'Net::LDAP'  => 0,
        'Test::Pod'  => 1.00,
    },
    META_MERGE => {
        'recommends' => {
            'HTML::Template' => 0,
            'HTTP::Message'  => 0,
            'Net::LDAP'      => 0,
            'XML::Simple'    => 0,
            'XML::LibXML'    => 0,
        },
    },
    PREREQ_PM => {
        'Apache::Session'      => 0,
        'Cache::Cache'         => 0,
        'CGI'                  => 3.08,
        'Crypt::OpenSSL::RSA'  => 0,
        'Crypt::OpenSSL::X509' => 0,
        'Crypt::Rijndael'      => 0,
        'Config::IniFiles'     => 0,
        'DBI'                  => 0,
        'File::Basename'       => 0,
        'Net::CIDR::Lite'      => 0,
        'Regexp::Assemble'     => 0,
        'SOAP::Lite'           => 0,
        'Storable'             => 0,
    },    # e.g., Module::Name => 1.1
          #EXE_FILES => [ 'scripts/convertConfig', ],
    (
        $] >= 5.005
        ?    ## Add these new keywords supported since 5.005
          (
            ABSTRACT_FROM =>
              'lib/Lemonldap/NG/Common.pm',    # retrieve abstract from module
            AUTHOR =>
'Xavier Guimard <x.guimard@free.fr>, Clément Oudot <clement@oodo.net>'
          )
        : ()
    ),
);
