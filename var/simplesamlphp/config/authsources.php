<?php
$config = array(
    'admin' => array(
        'core:AdminPassword',
    ),
    'ldap' => array(
        'ldap:LDAP',
        'hostname' => 'localhost',
        'enable_tls' => FALSE,
        'debug' => TRUE,
        'timeout' => 0,
        'port' => 389,
        'referrals' => TRUE,
        'attributes' => array(
            'cn', 
            'givenName', 
            'mail', 
            'sn', 
            'displayName',
            'employeeNumber',
            'title',
            'initials',
            'uid'
        ),
        'search.enable' => TRUE,
        'search.base' => 'dc=enabel,dc=be',
        'search.attributes' => array('uid', 'mail'),
        'search.username' => 'cn=admin,dc=enabel,dc=be',
        'search.password' => 'password',
        'priv.read' => FALSE,
        'priv.username' => NULL,
        'priv.password' => NULL,
    ),
);