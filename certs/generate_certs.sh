#!/bin/bash
# Generate self-signed certificates for OPC UA

# Create CA certificate
openssl req -x509 -newkey rsa:2048 -days 365 -nodes \
  -keyout ca_key.pem -out ca_cert.pem \
  -subj "/CN=OPC UA CA"

# Create server certificate
openssl req -new -newkey rsa:2048 -days 365 -nodes \
  -keyout server_key.pem -out server_csr.pem \
  -subj "/CN=OPC UA Server"

# Sign server certificate with CA
openssl x509 -req -in server_csr.pem -CA ca_cert.pem -CAkey ca_key.pem \
  -CAcreateserial -out server_cert.pem -days 365

# Create client certificate
openssl req -new -newkey rsa:2048 -days 365 -nodes \
  -keyout client_key.pem -out client_csr.pem \
  -subj "/CN=OPC UA Client"

# Sign client certificate with CA
openssl x509 -req -in client_csr.pem -CA ca_cert.pem -CAkey ca_key.pem \
  -CAcreateserial -out client_cert.pem -days 365

# Convert to DER format (OPC UA requires)
openssl x509 -in server_cert.pem -outform DER -out server_cert.der
openssl rsa -in server_key.pem -outform DER -out server_key.der

chmod 600 *.pem *.key *.der

echo "Certificates generated successfully!"
ls -lh *.pem *.der 2>/dev/null
