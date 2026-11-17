#!/bin/bash
########################  CREATE CA ####################################
# Create CA key  
openssl genrsa -aes256 -out KypydiyCA.key -passout pass:houston 2048

# Remove CA password 
openssl rsa -in KypydiyCA.key -out KypydiyCA.key -passin pass:houston

# Create CA configuration file  
cat > KypydiyCA.conf <<-EOF
default_bits = 2048
prompt = no
default_md = sha256
x509_extensions = v3_ca
distinguished_name = dn

[ dn ]
O=HOME
OU=HOME
emailAddress=kypydiy2027@gmail.com
CN = Kypydiy CA

[ v3_ca ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints       = critical, CA:TRUE
keyUsage               = critical, digitalSignature, cRLSign, keyCertSign
EOF

# create CA certificate 
openssl req -new -x509 -key KypydiyCA.key -out KypydiyCA.crt -days 3650 -config KypydiyCA.conf

# View CA certificate
openssl x509 -in KypydiyCA.crt -noout -text
