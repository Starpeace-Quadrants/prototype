#!/usr/bin/env bash
set -euo pipefail

CERTS_DIR="$(dirname "$0")/certs"
CLIENT_CERT_DIR="$(dirname "$0")/../gk-kafka-client/certs"
AUTH_CERT_DIR="$(dirname "$0")/../gk-kafka-hybrid-auth/certs"

mkdir -p "$CERTS_DIR" "$CLIENT_CERT_DIR" "$AUTH_CERT_DIR"

# Generate CA key and certificate
openssl genrsa -out "$CERTS_DIR/ca.key" 4096
openssl req -x509 -new -nodes -key "$CERTS_DIR/ca.key" -sha256 -days 3650 -out "$CERTS_DIR/ca.crt" -subj "/CN=gk-prototype-ca"

# Server certificate for the auth service
openssl genrsa -out "$CERTS_DIR/server.key" 2048
openssl req -new -key "$CERTS_DIR/server.key" -out "$CERTS_DIR/server.csr" -subj "/CN=gk-kafka-auth"
openssl x509 -req -in "$CERTS_DIR/server.csr" -CA "$CERTS_DIR/ca.crt" -CAkey "$CERTS_DIR/ca.key" -CAcreateserial -out "$CERTS_DIR/server.crt" -days 825 -sha256

# Client certificate for the client service
openssl genrsa -out "$CERTS_DIR/client.key" 2048
openssl req -new -key "$CERTS_DIR/client.key" -out "$CERTS_DIR/client.csr" -subj "/CN=gk-kafka-client"
openssl x509 -req -in "$CERTS_DIR/client.csr" -CA "$CERTS_DIR/ca.crt" -CAkey "$CERTS_DIR/ca.key" -CAcreateserial -out "$CERTS_DIR/client.crt" -days 825 -sha256

rm "$CERTS_DIR/server.csr" "$CERTS_DIR/client.csr" "$CERTS_DIR/ca.srl"

# Copy certificates to service repositories
cp "$CERTS_DIR/ca.crt" "$AUTH_CERT_DIR"/
cp "$CERTS_DIR/server.crt" "$AUTH_CERT_DIR"/
cp "$CERTS_DIR/server.key" "$AUTH_CERT_DIR"/

cp "$CERTS_DIR/ca.crt" "$CLIENT_CERT_DIR"/
cp "$CERTS_DIR/client.crt" "$CLIENT_CERT_DIR"/
cp "$CERTS_DIR/client.key" "$CLIENT_CERT_DIR"/

echo "Certificates generated in $CERTS_DIR and copied to service repos"