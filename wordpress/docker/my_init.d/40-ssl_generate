#!/bin/sh

cd /etc/ssl

echo "Generating CSR for wordpress.sirius-opg.uk"
openssl req -nodes -newkey rsa:2048 -keyout ssl.key -out ssl.csr -subj "/C=GB/ST=GB/L=London/O=OPG/OU=Digital/CN=wordpress.sirius-opg.uk"

echo "Signing CSR for wordpress.sirius-opg.uk"
openssl x509 -req -days 3650 -in ssl.csr -signkey ssl.key -out ssl.crt

