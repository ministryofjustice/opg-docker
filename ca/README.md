# CFSSL Certificate Authority

This repo is used to run a Certificate Authority with CFSSL

CFSSL binaries are installed. On startup the container will run these scripts.

1. 60-cfssl: start the CFSSL certificate authority server.
2. 90-cfssl-gencert: Generate container's own certificate and try to remote sign it with the CA.
3. 91-cfssl-cacert: Download and install the CA public cert from the CA.

It can be controlled via the following variables, some of them inherited from base container.

`OPG_CA_CLIENTAPIKEY` - Hex string for the password to use the client signing profile

`OPG_CA_SERVERAPIKEY` - Hex string for the password to use the server signing profile

`OPG_CA_CLIENTNAMEWHITELIST` - Regex string to limit the domains that will be signed for the client signing profile. Backslashes must be escaped for use in the json template.

`OPG_CA_CSR_CN`, `OPG_BASE_CSR_CN` - The `common name` attribute of the certificate.

`OPG_CA_CSR_HOSTS`, `OPG_BASE_CSR_HOSTS` - Comma separated list of hostnames to add to the certificates `SAN` field of the certificate.

`OPG_CA_DOMAIN`,`OPG_BASE_DOMAIN` - The base domain that is added to the hostname. Allows the cert to contain it's own container FQDN in the SAN field of the cert.

`SKIP_SSL_GENERATE` - If set will skip generation of the SSL cert on startup. This is separate to the CA's certifiate.

`OPG_BASE_CA_PROFILE` - The profile to communicate with the CA, the type of certificate signing and the cert filename. Choices are `client` or `server`. The CA does not need to remote sign with itself.

Example config.

```
OPG_CA_CLIENTAPIKEY=0123456789ABCDEF0123456789ABCDEF
# Re-escaped \ for regex use use inside json.
# Start of word - letters/numbers/dash multiple time - escaped dot - textual domain - end of word
OPG_CA_CLIENTNAMEWHITELIST=^[\\w-]+\\.qa.internal\\b|^[\\w-]+\\.alta.com\\b|^[\\w-]+\\.altb.com\\b|^[\\w-]+\\.dev.lpa.opg.digital\\b
OPG_CA_SERVERAPIKEY=0023456789ABCDEF0123456789ABCDEF
OPG_CA_CSR_CN=caserver.qa.internal
OPG_CA_CSR_HOSTS=ca.alt.a,ca.alt.b,ca.alt.c
OPG_CA_DOMAIN=qa.internal
OPG_BASE_DOMAIN=qa.internal
```

# Testing

Use the docker compose file to test remote signing certificates.

```
docker-compose up --build
```
