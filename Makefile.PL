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
	perl -i -pe 's/^(use constant DEFAULTCONFFILE =>).*\$\$/\$\$1 "$cf";/' blib/lib/Lemonldap/NG/Common/Conf.pm
EOT
    }
    return $r;
}

WriteMakefile(
    NAME         => 'Lemonldap::NG::Common',
    VERSION_FROM => 'lib/Lemonldap/NG/Common.pm',    # finds $VERSION
    PREREQ_PM    => {
        'CGI'              => 3.08,
        'DBI'              => 0,
        'Storable'         => 0,
        'Regexp::Assemble' => 0,
        'Cache::Cache'     => 0,
        'IO::String'       => 0,
        'SOAP::Lite'       => 0,
        'Crypt::Rijndael'  => 0,
        'HTTP::Headers'    => 0,
    },                                               # e.g., Module::Name => 1.1
    #EXE_FILES => [ 'scripts/lmConfig_File2MySQL', ],
    (
        $] >= 5.005
        ?    ## Add these new keywords supported since 5.005
          (
            ABSTRACT_FROM =>
              'lib/Lemonldap/NG/Common.pm',    # retrieve abstract from module
            AUTHOR => 'guimard <guimard@>'
          )
        : ()
    ),
);
