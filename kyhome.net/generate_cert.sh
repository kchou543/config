#!/bin/bash 
domainname=kyhome.net

########################  CREATE SERVER CERTIFICATE ###################################
# create key pair 
openssl genrsa -aes256 -out cert-${domainname}.key -passout pass:houston 2048

# remove password
openssl rsa -in cert-${domainname}.key  -out cert-${domainname}.key -passin pass:houston


# create CSR conf :
cat > csr.conf <<-EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = v3_req
distinguished_name = dn

[ dn ]
O=HOME
emailAddress=kypydiy2027@gmail.com
CN = *.kyhome.net

[ v3_req ]
basicConstraints = CA:FALSE
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = *.kyhome.net
EOF

# create csr :
openssl req -new -sha256 -nodes -out cert-${domainname}.csr -key cert-${domainname}.key -config csr.conf

# sign csr to create crt :
openssl x509 -req -in cert-${domainname}.csr -CAkey KypydiyCA.key -CA KypydiyCA.crt -days 1825 -out cert-${domainname}.crt -CAcreateserial -extensions v3_req -extfile csr.conf

# verify via text
openssl x509 -in cert-${domainname}.crt -text -noout
