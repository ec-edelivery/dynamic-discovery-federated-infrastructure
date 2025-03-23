insert into bdmsl_configuration(property, value, description, created_on, last_updated_on) values
('authentication.bluecoat.enabled','true','Enable/Disable Client-Cert header authentication. Possible values: true/false.', NOW(), NOW()),
('authentication.sslclientcert.enabled','true','Enable/Disable SSLClientCert header authentication. Possible values: true/false', NOW(), NOW()),
('useProxy','false','true if a proxy is required to connect to the internet. Possible values: true/false', NOW(), NOW()),
('unsecureLoginAllowed','false','true if the use of HTTPS is not required. If the value is set to true, then the user unsecure-http-client is automatically created. Possible values: true/false', NOW(), NOW()),
('signResponse','false','true if the responses must be signed. Possible values: true/false', NOW(), NOW()),
('keystorePassword','{}','Base64 encrypted password for Keystore.', NOW(), NOW()),
('keystoreFileName','keystore.p12','The keystore file. Should be just the filename if the file is in the classpath or in the configurationDir', NOW(), NOW()),
('keystoreType','PKCS12','The keystore type. Possible values: JKS/PKCS12.', NOW(), NOW()),
('keystoreAlias','domisml_rsa4096','The alias in the keystore.', NOW(), NOW()),
('encriptionPrivateKey','encriptionPrivateKey.private','Name of the 256 bit AES secret key to encrypt or decrypt passwords.', NOW(), NOW()),
('dnsClient.server','${DNS_HOSTNAME}','The DNS server', NOW(), NOW()),
('dnsClient.enabled','${DNS_ENABLED}','true if registration of DNS records is required. Must be true in production. Possible values: true/false', NOW(), NOW()),
('dnsClient.show.entries','true','if true than service ListDNS transfer and show the DNS entries. (Not recommended for large zones). Possible values: true/false', NOW(), NOW()),
('dnsClient.SIG0Enabled','false','true if the SIG0 signing is enabled. Required fr DNSSEC. Possible values: true/false', NOW(), NOW()),
('dnsClient.SIG0PublicKeyName', '', 'The public key name of the SIG0 key',NOW(),NOW()),
('dnsClient.SIG0KeyFileName', '', 'The actual SIG0 key file. Should be just the filename if the file is in the classpath or in the ''configurationDir''',NOW(),NOW()),
('dataInconsistencyAnalyzer.cronJobExpression','0 0 3 ? * *','Cron expression for dataInconsistencyChecker job. Example: 0 0 3 ? * * (everyday at 3:00 am)', NOW(), NOW()),
('configurationDir','${CONFIGURATION_FOLDER}','The absolute path to the folder containing all the configuration files (keystore and sig0 key)', NOW(), NOW()),
('authorization.smp.certSubjectRegex','^.*(CN=SMP_|OU=PEPPOL TEST SMP).*$','User with ROOT-CA is granted SMP_ROLE only if its certificates Subject matches configured regexp', NOW(), NOW()),
('sml.property.refresh.cronJobExpression','5 */1 * * * *','Properties update', NOW(), NOW());


insert into bdmsl_subdomain(subdomain_id, subdomain_name,dns_zone, description, participant_id_regexp, dns_record_types, smp_url_schemas, created_on, last_updated_on) values
(1, '${DNS_DOMAIN}', '${DNS_ZONE}','Domain for ${DNS_DOMAIN}', '${PARTICIPANT_ID_REGEXP}','naptr','all', NOW(), NOW());


INSERT INTO bdmsl_certificate_domain(certificate, crl_url,  is_root_ca, fk_subdomain_id, created_on, last_updated_on, is_admin) VALUES
('CN=Test intermediate Issuer 01,OU=eDelivery,O=DIGIT,C=BE','',1, 1, NOW(), NOW(),0),
('CN=AdministratorSML,OU=B4,O=DIGIT,C=BE','',0, 1, NOW(), NOW(),1);






