##@file
# All configuration attributes

##@class
# All configuration attributes

package Lemonldap::NG::Common::Conf::Attributes;

use Mouse;

our $VERSION = 1.4.1;

## A

has 'activeTimer' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'Enable timers on portal pages',
);

has 'apacheAuthnLevel' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '4',
    documentation => 'Apache authentication level',
);

has 'applicationList' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub {
        return {
            'default' => { catname => 'Default category', type => "category" },
        };
    },
    documentation => 'Applications list',
);

has 'authChoiceParam' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'lmAuth',
    documentation => 'HTTP parameter to store choosen authentication method',
);

has 'authentication' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'Demo',
    documentation => 'Authentication module',
);

## B

has 'browserIdAuthnLevel' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '1',
    documentation => 'Browser ID authentication level',
);

## C

has 'captcha_login_enabled' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'Captcha on login page',
);

has 'captcha_mail_enabled' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'Captcha on password reset page',
);

has 'captcha_register_enabled' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'Captcha on account creation page',
);

has 'captcha_size' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '6',
    documentation => 'Captcha size',
);

has 'captchaStorage' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'Apache::Session::File',
    documentation => 'Captcha backend module',
);

has 'captchaStorageOptions' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub {
        return { 'Directory' => '/var/lib/lemonldap-ng/captcha/', };
    },
    documentation => 'Captcha backend module options',
);

has 'casAccessControlPolicy' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'none',
    documentation => 'CAS access control policy',
);

has 'CAS_authnLevel' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '1',
    documentation => 'CAS authentication level',
);

has 'CAS_pgtFile' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '/tmp/pgt.txt',
    documentation => 'CAS PGT file',
);

has 'cda' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'Enable Cross Domain Authentication',
);

has 'cfgNum' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '0',
    documentation => 'Configuration number',
);

has 'checkXSS' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'Check XSS',
);

has 'confirmFormMethod' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'post',
    documentation => 'HTTP method for confirm page form',
);

has 'cookieName' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'lemonldap',
    documentation => 'Name of the cookie',
);

## D

has 'dbiAuthnLevel' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '2',
    documentation => 'DBI authentication level',
);

has 'dbiExportedVars' => (
    is            => 'rw',
    isa           => 'HashRef',
    default       => sub { return {}; },
    documentation => 'DBI exported variables',
);

has 'demoExportedVars' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { return { cn => 'cn', mail => 'mail', uid => 'uid', }; },
    documentation => 'Demo exported variables',
);

has 'domain' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'example.com',
    documentation => 'DNS domain',
);

## E

has 'exportedVars' => (
    is            => 'rw',
    isa           => 'HashRef',
    default       => sub { return { 'UA' => 'HTTP_USER_AGENT' }; },
    documentation => 'Main exported variables',
);

## F

has 'facebookAuthnLevel' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '1',
    documentation => 'Facebook authentication level',
);

has 'facebookExportedVars' => (
    is            => 'rw',
    isa           => 'HashRef',
    default       => sub { return {}; },
    documentation => 'Facebook exported variables',
);

has 'failedLoginNumber' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '5',
    documentation => 'Number of failures stored in login history',
);

## G

has 'globalStorage' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'Apache::Session::File',
    documentation => 'Session backend module',
);

has 'globalStorageOptions' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub {
        return {
            'Directory'     => '/var/lib/lemonldap-ng/sessions/',
            'LockDirectory' => '/var/lib/lemonldap-ng/sessions/lock/',
            'generateModule' =>
              'Lemonldap::NG::Common::Apache::Session::Generate::SHA256',
        };
    },
    documentation => 'Session backend module options',
);

has 'googleAuthnLevel' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '1',
    documentation => 'Google authentication level',
);

has 'googleExportedVars' => (
    is            => 'rw',
    isa           => 'HashRef',
    default       => sub { return {}; },
    documentation => 'Google exported variables',
);

has 'groups' => (
    is            => 'rw',
    isa           => 'HashRef',
    default       => sub { return {}; },
    documentation => 'Groups',
);

## H

has 'hiddenAttributes' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '_password',
    documentation => 'Name of attributes to hide in logs',
);

has 'hideOldPassword' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'Hide old password in portal',
);

has 'httpOnly' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'Enable httpOnly flag in cookie',
);

has 'https' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'Use HTTPS for redirection from portal',
);

## I

has 'infoFormMethod' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'get',
    documentation => 'HTTP method for info page form',
);

has 'issuerDBCASActivation' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'CAS server activation',
);

has 'issuerDBCASPath' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '^/cas/',
    documentation => 'CAS server request path',
);

has 'issuerDBCASRule' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '1',
    documentation => 'CAS server rule',
);

has 'issuerDBOpenIDActivation' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'OpenID server activation',
);

has 'issuerDBOpenIDPath' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '^/openidserver/',
    documentation => 'OpenID server request path',
);

has 'issuerDBOpenIDRule' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '1',
    documentation => 'OpenID server rule',
);

has 'issuerDBSAMLActivation' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'SAML IDP activation',
);

has 'issuerDBSAMLPath' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '^/saml/',
    documentation => 'SAML IDP request path',
);

has 'issuerDBSAMLRule' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '1',
    documentation => 'SAML IDP rule',
);

## J

has 'jsRedirect' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '0',
    documentation => 'Use javascript for redirections',
);

## K

has 'key' => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        return join( '', map { chr( int( rand(94) ) + 33 ) } ( 1 .. 16 ) );
    },
    documentation => 'Secret key',
);

## L

has 'ldapAuthnLevel' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '2',
    documentation => 'LDAP authentication level',
);

has 'ldapBase' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'dc=example,dc=com',
    documentation => 'LDAP search base',
);

has 'ldapExportedVars' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { return { cn => 'cn', mail => 'mail', uid => 'uid', }; },
    documentation => 'LDAP exported variables',
);

has 'ldapGroupAttributeName' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'member',
    documentation => 'LDAP attribute name for member in groups',
);

has 'ldapGroupAttributeNameGroup' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'dn',
    documentation =>
      'LDAP attribute name in group entry referenced as member in groups',
);

has 'ldapGroupAttributeNameSearch' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'cn',
    documentation => 'LDAP attributes to search in groups',
);

has 'ldapGroupAttributeNameUser' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'dn',
    documentation =>
      'LDAP attribute name in user entry referenced as member in groups',
);

has 'ldapGroupObjectClass' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'groupOfNames',
    documentation => 'LDAP object class of groups',
);

has 'ldapGroupRecursive' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'LDAP recursive search in groups',
);

has 'ldapPasswordResetAttribute' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'pwdReset',
    documentation => 'LDAP password reset attribute',
);

has 'ldapPasswordResetAttributeValue' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'TRUE',
    documentation => 'LDAP password reset value',
);

has 'ldapPwdEnc' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'utf-8',
    documentation => 'LDAP password encoding',
);

has 'ldapPort' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '389',
    documentation => 'LDAP port',
);

has 'ldapServer' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'ldap://localhost',
    documentation => 'LDAP server (host or URI)',
);

has 'ldapTimeout' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '120',
    documentation => 'LDAP connection timeout',
);

has 'ldapUsePasswordResetAttribute' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'LDAP store reset flag in an attribute',
);

has 'ldapVersion' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '3',
    documentation => 'LDAP protocol version',
);

has 'localSessionStorage' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'Cache::FileCache',
    documentation => 'Sessions cache module',
);

has 'localSessionStorageOptions' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub {
        return {
            'namespace'          => 'lemonldap-ng-sessions',
            'default_expires_in' => 600,
            'directory_umask'    => '007',
            'cache_root'         => '/tmp',
            'cache_depth'        => 3,
        };
    },
    documentation => 'Sessions cache module options',
);

has 'loginHistoryEnabled' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'Enable login history',
);

has 'logoutServices' => (
    is            => 'rw',
    isa           => 'HashRef',
    default       => sub { return {}; },
    documentation => 'Send logout trough GET request to these services',
);

## M

has 'macros' => (
    is            => 'rw',
    isa           => 'HashRef',
    default       => sub { return {}; },
    documentation => 'Macros',
);

has 'mailCharset' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'utf-8',
    documentation => 'Mail charset',
);

has 'mailConfirmSubject' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '[LemonLDAP::NG] Password reset confirmation',
    documentation => 'Mail subject for reset confirmation',
);

has 'mailFrom' => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        my $self = shift;
        my $domain = $self ? $self->domain : "example.com";
        return "noreply@" . $domain;
    },
    lazy          => 1,
    documentation => 'Sender email',
);

has 'mailSessionKey' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'mail',
    documentation => 'Session parameter where mail is stored',
);

has 'mailOnPasswordChange' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'Send a mail when password is changed',
);

has 'mailSessionKey' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'mail',
    documentation => 'Session parameter where mail is stored',
);

has 'mailSubject' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '[LemonLDAP::NG] Your new password',
    documentation => 'Mail subject for new password email',
);

has 'mailTimeout' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '0',
    documentation => 'Mail session timeout',
);

has 'mailUrl' => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        my $self = shift;
        my $portal = $self ? $self->portal : "http://auth.example.com/";
        return $portal . "mail.pl";
    },
    lazy          => 1,
    documentation => 'URL of password reset page',
);

has 'maintenance' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'Maintenance mode for all virtual hosts',
);

has 'managerDn' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '',
    documentation => 'LDAP manager DN',
);

has 'managerPassword' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '',
    documentation => 'LDAP manager Password',
);

has 'multiValuesSeparator' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '; ',
    documentation => 'Separator for multiple values',
);

## N

has 'notification' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'Notification activation',
);

has 'notificationStorage' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'File',
    documentation => 'Notification backend',
);

has 'notificationStorageOptions' => (
    is  => 'rw',
    isa => 'HashRef',
    default =>
      sub { return { dirName => '/var/lib/lemonldap-ng/notifications', }; },
    documentation => 'Notification backend options',
);

has 'notificationWildcard' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'allusers',
    documentation => 'Notification string to match all users',
);

has 'notifyDeleted' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'Show deleted sessions in portal',
);

has 'notifyOther' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'Show other sessions in portal',
);

has 'nullAuthnLevel' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '2',
    documentation => 'Null authentication level',
);

## O

has 'openIdAuthnLevel' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '1',
    documentation => 'OpenID authentication level',
);

has 'openIdExportedVars' => (
    is            => 'rw',
    isa           => 'HashRef',
    default       => sub { return {}; },
    documentation => 'OpenID exported variables',
);

has 'openIdSreg_email' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'mail',
    documentation => 'OpenID SREG email session parameter',
);

has 'openIdSreg_fullname' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'cn',
    documentation => 'OpenID SREG fullname session parameter',
);

has 'openIdSreg_nickname' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'uid',
    documentation => 'OpenID SREG nickname session parameter',
);

has 'openIdSreg_timezone' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '_timezone',
    documentation => 'OpenID SREG timezone session parameter',
);

## P

has 'passwordDB' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'Demo',
    documentation => 'Password module',
);

has 'portal' => (
    is            => 'rw',
    isa           => 'Any',
    default       => 'http://auth.example.com/',
    documentation => 'Portal URL',
);

has 'portalAntiFrame' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'Avoid portal to be displayed inside frames',
);

has 'portalAutocomplete' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'Allow autocompletion of login input in portal',
);

has 'portalCheckLogins' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'Display login history checkbox in portal',
);

has 'portalDisplayAppslist' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '1',
    documentation => 'Display applications tab in portal',
);

has 'portalDisplayChangePassword' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '$_auth =~ /^(LDAP|DBI|Demo)$/',
    documentation => 'Display password tab in portal',
);

has 'portalDisplayLoginHistory' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '1',
    documentation => 'Display login history tab in portal',
);

has 'portalDisplayLogout' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '1',
    documentation => 'Display logout tab in portal',
);

has 'portalDisplayRegister' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '1',
    documentation => 'Display register button in portal',
);

has 'portalDisplayResetPassword' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '1',
    documentation => 'Display reset password button in portal',
);

has 'portalForceAuthn' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'Force to authenticate when displaying portal',
);

has 'portalForceAuthnInterval' => (
    is      => 'rw',
    isa     => 'Int',
    default => '0',
    documentation =>
'Minimum number of seconds since last authentifcation to force reauthentication',
);

has 'portalOpenLinkInNewWindow' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'Open applications in new windows',
);

has 'portalPingInterval' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '60000',
    documentation => 'Interval in ms between portal Ajax pings ',
);

has 'portalRequireOldPassword' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'Old password is required to change the password',
);

has 'portalSkin' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'bootstrap',
    documentation => 'Name of portal skin',
);

has 'portalUserAttr' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '_user',
    documentation => 'Session parameter to display connected user in portal',
);

has 'protection' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'none',
    documentation => 'Manager protection method',
);

## Q

## R

has 'radiusAuthnLevel' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '3',
    documentation => 'Radius authentication level',
);

has 'randomPasswordRegexp' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '[A-Z]{3}[a-z]{5}.\d{2}',
    documentation => 'Regular expression to create a random password',
);

has 'redirectFormMethod' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'get',
    documentation => 'HTTP method for redirect page form',
);

has 'registerConfirmSubject' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '[LemonLDAP::NG] Account register confirmation',
    documentation => 'Mail subject for register confirmation',
);

has 'registerDB' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'Demo',
    documentation => 'Register module',
);

has 'registerDoneSubject' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '[LemonLDAP::NG] Your new account',
    documentation => 'Mail subject when register is done',
);

has 'registerTimeout' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '0',
    documentation => 'Register session timeout',
);

has 'registerUrl' => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        my $self = shift;
        my $portal = $self ? $self->portal : "http://auth.example.com/";
        return $portal . "register.pl";
    },
    lazy          => 1,
    documentation => 'URL of register page',
);

has 'remoteGlobalStorage' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'Lemonldap::NG::Common::Apache::Session::SOAP',
    documentation => 'Remote session backend',
);

has 'remoteGlobalStorageOptions' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub {
        my $self = shift;
        my $portal = $self ? $self->portal : "http://auth.example.com/";
        return {
            'proxy' => $portal . 'index.pl/sessions',
            'ns'    => $portal . 'Lemonldap/NG/Common/CGI/SOAPService',
        };
    },
    lazy          => 1,
    documentation => 'Demo exported variables',
);

## S

has 'samlAttributeAuthorityDescriptorAttributeServiceSOAP' => (
    is  => 'rw',
    isa => 'Str',
    default =>
      'urn:oasis:names:tc:SAML:2.0:bindings:SOAP;#PORTAL#/saml/AA/SOAP;',
    documentation => 'SAML Attribute Authority SOAP',
);

has 'samlAuthnContextMapKerberos' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '4',
    documentation => 'SAML authn context kerberos level',
);

has 'samlAuthnContextMapPassword' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '2',
    documentation => 'SAML authn context password level',
);

has 'samlAuthnContextMapPasswordProtectedTransport' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '3',
    documentation => 'SAML authn context password protected transport level',
);

has 'samlAuthnContextMapTLSClient' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '5',
    documentation => 'SAML authn context TLS client level',
);

has 'samlCommonDomainCookieActivation' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'SAML CDC activation',
);

has 'samlEntityID' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '#PORTAL#/saml/metadata',
    documentation => 'SAML service entityID',
);

has 'samlIdPResolveCookie' => (
    is      => 'rw',
    isa     => 'Str',
    default => sub {
        my $self = shift;
        my $cookieName = $self ? $self->cookieName : "lemonldap";
        return $cookieName . "idp";
    },
    lazy          => 1,
    documentation => 'SAML IDP resolution cookie',
);

has 'samlIDPSSODescriptorArtifactResolutionServiceArtifact' => (
    is  => 'rw',
    isa => 'Str',
    default =>
      '1;0;urn:oasis:names:tc:SAML:2.0:bindings:SOAP;#PORTAL#/saml/artifact',
    documentation => 'SAML IDP artifact resolution service',
);

has 'samlIDPSSODescriptorSingleLogoutServiceHTTPPost' => (
    is  => 'rw',
    isa => 'Str',
    default =>
'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST;#PORTAL#/saml/singleLogout;#PORTAL#/saml/singleLogoutReturn',
    documentation => 'SAML IDP SLO HTTP POST',
);

has 'samlIDPSSODescriptorSingleLogoutServiceHTTPRedirect' => (
    is  => 'rw',
    isa => 'Str',
    default =>
'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect;#PORTAL#/saml/singleLogout;#PORTAL#/saml/singleLogoutReturn',
    documentation => 'SAML IDP SLO HTTP Redirect',
);

has 'samlIDPSSODescriptorSingleLogoutServiceSOAP' => (
    is  => 'rw',
    isa => 'Str',
    default =>
'urn:oasis:names:tc:SAML:2.0:bindings:SOAP;#PORTAL#/saml/singleLogoutSOAP;',
    documentation => 'SAML IDP SLO SOAP',
);

has 'samlIDPSSODescriptorSingleSignOnServiceHTTPArtifact' => (
    is  => 'rw',
    isa => 'Str',
    default =>
'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact;#PORTAL#/saml/singleSignOnArtifact;',
    documentation => 'SAML IDP SSO HTTP Artifact',
);

has 'samlIDPSSODescriptorSingleSignOnServiceHTTPPost' => (
    is  => 'rw',
    isa => 'Str',
    default =>
'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST;#PORTAL#/saml/singleSignOn;',
    documentation => 'SAML IDP SSO HTTP POST',
);

has 'samlIDPSSODescriptorSingleSignOnServiceHTTPRedirect' => (
    is  => 'rw',
    isa => 'Str',
    default =>
'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect;#PORTAL#/saml/singleSignOn;',
    documentation => 'SAML IDP SSO HTTP Redirect',
);

has 'samlIDPSSODescriptorSingleSignOnServiceSOAP' => (
    is  => 'rw',
    isa => 'Str',
    default =>
'urn:oasis:names:tc:SAML:2.0:bindings:SOAP;#PORTAL#/saml/singleSignOnSOAP;',
    documentation => 'SAML IDP SSO SOAP',
);

has 'samlIDPSSODescriptorWantAuthnRequestsSigned' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'SAML IDP want authn request signed',
);

has 'samlMetadataForceUTF8' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'SAML force metadata UTF8 conversion',
);

has 'samlNameIDFormatMapEmail' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'mail',
    documentation => 'SAML session parameter for NameID email',
);

has 'samlNameIDFormatMapKerberos' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'uid',
    documentation => 'SAML session parameter for NameID kerberos',
);

has 'samlNameIDFormatMapWindows' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'uid',
    documentation => 'SAML session parameter for NameID windows',
);

has 'samlNameIDFormatMapX509' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'mail',
    documentation => 'SAML session parameter for NameID x509',
);
has 'samlOrganizationDisplayName' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'Example',
    documentation => 'SAML service organization display name',
);

has 'samlOrganizationName' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'Example',
    documentation => 'SAML service organization name',
);

has 'samlOrganizationURL' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'http://www.example.com',
    documentation => 'SAML service organization URL',
);

has 'samlRelayStateTimeout' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '600',
    documentation => 'SAML timeout of relay state',
);

has 'samlSPSSODescriptorArtifactResolutionServiceArtifact' => (
    is  => 'rw',
    isa => 'Str',
    default =>
      '1;0;urn:oasis:names:tc:SAML:2.0:bindings:SOAP;#PORTAL#/saml/artifact',
    documentation => 'SAML SP artifact resolution service ',
);

has 'samlSPSSODescriptorAssertionConsumerServiceHTTPArtifact' => (
    is  => 'rw',
    isa => 'Str',
    default =>
'1;0;urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact;#PORTAL#/saml/proxySingleSignOnArtifact',
    documentation => 'SAML SP ACS HTTP artifact',
);

has 'samlSPSSODescriptorAssertionConsumerServiceHTTPPost' => (
    is  => 'rw',
    isa => 'Str',
    default =>
'0;1;urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST;#PORTAL#/saml/proxySingleSignOnPost',
    documentation => 'SAML SP ACS HTTP POST',
);

has 'samlSPSSODescriptorAuthnRequestsSigned' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'SAML SP AuthnRequestsSigned',
);

has 'samlSPSSODescriptorSingleLogoutServiceHTTPPost' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST;'
      . '#PORTAL#'
      . '/saml/proxySingleLogout;'
      . '#PORTAL#'
      . '/saml/proxySingleLogoutReturn',
    documentation => 'SAML SP SLO HTTP POST',
);

has 'samlSPSSODescriptorSingleLogoutServiceHTTPRedirect' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect;'
      . '#PORTAL#'
      . '/saml/proxySingleLogout;'
      . '#PORTAL#'
      . '/saml/proxySingleLogoutReturn',
    documentation => 'SAML SP SLO HTTP Redirect',
);

has 'samlSPSSODescriptorSingleLogoutServiceSOAP' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'urn:oasis:names:tc:SAML:2.0:bindings:SOAP;'
      . '#PORTAL#'
      . '/saml/proxySingleLogoutSOAP;',
    documentation => 'SAML SP SLO SOAP',
);

has 'samlSPSSODescriptorWantAssertionsSigned' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'SAML SP WantAssertionsSigned',
);

has 'samlServicePrivateKeyEnc' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '',
    documentation => 'SAML encryption private key',
);

has 'samlServicePrivateKeyEncPwd' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '',
    documentation => 'SAML encryption private key password',
);

has 'samlServicePrivateKeySig' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '',
    documentation => 'SAML signature private key',
);

has 'samlServicePrivateKeySigPwd' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '',
    documentation => 'SAML signature private key password',
);

has 'samlServicePublicKeyEnc' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '',
    documentation => 'SAML encryption public key',
);

has 'samlServicePublicKeySig' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '',
    documentation => 'SAML signature public key',
);

has 'samlUseQueryStringSpecific' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'SAML use specific method for query_string',
);

has 'securedCookie' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '0',
    documentation => 'Cookie securisation method',
);

has 'secureTokenAllowOnError' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'Secure Token Handler allow request on error',
);

has 'secureTokenAttribute' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'uid',
    documentation => 'Secure Token Handler attribute to store',
);

has 'secureTokenExpiration' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '60',
    documentation => 'Secure Token Handler token expiration',
);

has 'secureTokenHeader' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'Auth-Token',
    documentation => 'Secure Token Handler header name',
);

has 'secureTokenMemcachedServers' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '127.0.0.1:11211',
    documentation => 'Secure Token Handler memcached servers',
);

has 'secureTokenUrls' => (
    is      => 'rw',
    isa     => 'Str',
    default => '.*',
    documentation =>
      'Secure Token Handler regular expression to match protected URL',
);

has 'singleIP' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'Allow only one session per IP',
);

has 'singleSession' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'Allow only one session per user',
);

has 'singleSessionUserByIP' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'Allow only one session per user on an IP',
);

has 'slaveAuthnLevel' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '2',
    documentation => 'Slave authentication level',
);

has 'slaveExportedVars' => (
    is            => 'rw',
    isa           => 'HashRef',
    default       => sub { return {}; },
    documentation => 'Slave exported variables',
);

has 'SMTPServer' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '',
    documentation => 'SMTP Server',
);

has 'Soap' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'Enable SOAP services',
);

has 'storePassword' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'Store password in session',
);

has 'SSLAuthnLevel' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '5',
    documentation => 'SSL authentication level',
);

has 'successLoginNumber' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '5',
    documentation => 'Number of success stored in login history',
);

has 'syslog' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '',
    documentation => 'Syslog facility',
);

## T

has 'timeout' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '72000',
    documentation => 'Session timeout on server side',
);

has 'timeoutActivity' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '0',
    documentation => 'Session activity timeout on server side',
);

has 'trustedProxies' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '',
    documentation => 'Trusted proxies',
);

has 'twitterAuthnLevel' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '1',
    documentation => 'Twitter authentication level',
);

## U

has 'userControl' => (
    is            => 'rw',
    isa           => 'Str',
    default       => '^[\w\.\-@]+$',
    documentation => 'Regular expression to validate login',
);

has 'userDB' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'Demo',
    documentation => 'User module',
);

has 'useRedirectOnError' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'Use 302 redirect code for error (500)',
);

has 'useRedirectOnForbidden' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '0',
    documentation => 'Use 302 redirect code for forbidden (403)',
);

has 'useSafeJail' => (
    is            => 'rw',
    isa           => 'Bool',
    default       => '1',
    documentation => 'Activate Safe jail',
);

## V

## W

has 'webIDAuthnLevel' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '1',
    documentation => 'WebID authentication level',
);

has 'webIDExportedVars' => (
    is            => 'rw',
    isa           => 'HashRef',
    default       => sub { return {}; },
    documentation => 'WebID exported variables',
);

has 'whatToTrace' => (
    is            => 'rw',
    isa           => 'Str',
    default       => 'uid',
    documentation => 'Session parameter used to fill REMOTE_USER',
);

## X

## Y

has 'yubikeyAuthnLevel' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '3',
    documentation => 'Yubikey authentication level',
);

has 'yubikeyPublicIDSize' => (
    is            => 'rw',
    isa           => 'Int',
    default       => '12',
    documentation => 'Yubikey public ID size',
);

## Z

no Mouse;

1;
