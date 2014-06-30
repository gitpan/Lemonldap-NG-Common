##@file
# Some configuration subattributes

##@class
#Some configuration subattributes

package Lemonldap::NG::Common::Conf::SubAttributes;

use Mouse;

our $VERSION = 1.4.0;

## E

has 'exportedHeaders' => (
    is            => 'rw',
    isa           => 'HashRef',
    default       => sub { return { 'Auth-User' => '$uid' }; },
    documentation => "Headers for a virtual host",
);

## L

has 'locationRules' => (
    is            => 'rw',
    isa           => 'HashRef',
    default       => sub { return { default => 'deny' }; },
    documentation => "Rules for a virtual host",
);

## P

has 'post' => (
    is            => 'rw',
    isa           => 'HashRef',
    default       => sub { return { none => { expr => {}, }, }; },
    documentation => "Form replay for a virtual host",
);

## S

has 'samlIDPMetaDataExportedAttributes' => (
    is            => 'rw',
    isa           => 'HashRef',
    default       => sub { return { 'uid' => '0;uid;;' }; },
    documentation => "Exported attributes for an IDP",
);

has 'samlIDPMetaDataOptionsAdaptSessionUtime' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'SAML IDP option adapt session utime',
);

has 'samlIDPMetaDataOptionsAllowLoginFromIDP' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'SAML IDP option allow SSO IDP initiated',
);

has 'samlIDPMetaDataOptionsAllowProxiedAuthn' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'SAML IDP option allow IDP proxy',
);

has 'samlIDPMetaDataOptionsCheckConditions' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'SAML IDP option check conditions',
);

has 'samlIDPMetaDataOptionsCheckSLOMessageSignature' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'SAML IDP option check SLO signature',
);

has 'samlIDPMetaDataOptionsCheckSSOMessageSignature' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'SAML IDP option check SSO signature',
);

has 'samlIDPMetaDataOptionsEncryptionMode' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'none',
    documentation => 'SAML IDP option encryption mode',
);

has 'samlIDPMetaDataOptionsForceAuthn' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'SAML IDP option force authentication',
);

has 'samlIDPMetaDataOptionsForceUTF8' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'SAML IDP option force UTF-8',
);

has 'samlIDPMetaDataOptionsIsPassive' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'SAML IDP option is passive',
);

has 'samlIDPMetaDataOptionsNameIDFormat' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '',
    documentation => 'SAML IDP option NameID format',
);

has 'samlIDPMetaDataOptionsRequestedAuthnContext' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '',
    documentation => 'SAML IDP option requested authentication context',
);

has 'samlIDPMetaDataOptionsResolutionRule' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '',
    documentation => 'SAML IDP option resolution rule',
);

has 'samlIDPMetaDataOptionsSLOBinding' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '',
    documentation => 'SAML IDP option SLO binding',
);

has 'samlIDPMetaDataOptionsSSOBinding' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '',
    documentation => 'SAML IDP option SSO binding',
);

has 'samlIDPMetaDataOptionsSignSLOMessage' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'SAML IDP option sign SLO',
);

has 'samlIDPMetaDataOptionsSignSSOMessage' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'SAML IDP option sign SSO',
);

has 'samlSPMetaDataExportedAttributes' => (
    is            => 'rw',
    isa           => 'HashRef',
    default       => sub { return { 'uid' => '0;uid;;' }; },
    documentation => "Exported attributes for a SP",
);

has 'samlSPMetaDataOptionsCheckSLOMessageSignature' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'SAML SP option check SLO',
);

has 'samlSPMetaDataOptionsCheckSSOMessageSignature' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'SAML SP option check SLO',
);

has 'samlSPMetaDataOptionsEnableIDPInitiatedURL' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'SAML SP option enable SSO IDP initiated URL',
);

has 'samlSPMetaDataOptionsEncryptionMode' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'none',
    documentation => 'SAML SP option encryption mode',
);

has 'samlSPMetaDataOptionsNameIDFormat' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '',
    documentation => 'SAML SP option NameID format',
);

has 'samlSPMetaDataOptionsOneTimeUse' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'SAML SP option one time use',
);

has 'samlSPMetaDataOptionsSignSLOMessage' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'SAML SP option sign SLO',
);

has 'samlSPMetaDataOptionsSignSSOMessage' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'SAML SP option sign SSO',
);

## V

has 'vhostAliases' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '',
    documentation => 'Aliases for a virtual host',
);

has 'vhostHttps' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '-1',
    documentation => 'HTTPS mode for a virtual host',
);

has 'vhostMaintenance' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'Maintenance mode for a virtual host',
);

has 'vhostOptions' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub {
        my $self = shift;
        return {
            vhostPort        => $self->vhostPort,
            vhostHttps       => $self->vhostHttps,
            vhostMaintenance => $self->vhostMaintenance,
            vhostAliases     => $self->vhostAliases,
        };
    },
    lazy          => 1,
    documentation => 'Options for a virtual host',
);

has 'vhostPort' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '-1',
    documentation => 'Redirection port for a virtual host',
);

no Mouse;

1;
