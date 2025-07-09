#!/usr/bin/env bash
set -euo pipefail

CERTS_DIR="$(dirname "$0")/certs"
CLIENT_CERT_DIR="$(dirname "$0")/../gk-kafka-client/certs"
AUTH_CERT_DIR="$(dirname "$0")/../gk-kafka-hybrid-auth/certs"
TRAEFIK_DIR="$(dirname "$0")/.docker/traefik"

mkdir -p "$CERTS_DIR" "$CLIENT_CERT_DIR" "$AUTH_CERT_DIR" "$TRAEFIK_DIR"

# Generate CA key and certificate
openssl genrsa -out "$CERTS_DIR/ca.key" 4096
openssl req -x509 -new -nodes -key "$CERTS_DIR/ca.key" -sha256 -days 3650 -out "$CERTS_DIR/ca.crt" -subj "/CN=gk-prototype-ca"

# Traefik certificate covering all hosts served locally
cat > "$CERTS_DIR/traefik.cnf" <<EOT
[req]
distinguished_name = dn
req_extensions = ext
prompt = no
[dn]
CN = traefik.localhost
[ext]
subjectAltName = @alt_names
[alt_names]
DNS.1 = monitor.localhost
DNS.2 = kafdrop.localhost
DNS.3 = client.localhost
DNS.4 = relay.localhost
DNS.5 = auth.localhost
EOT

openssl genrsa -out "$CERTS_DIR/traefik.key" 2048
openssl req -new -key "$CERTS_DIR/traefik.key" -out "$CERTS_DIR/traefik.csr" -config "$CERTS_DIR/traefik.cnf"
openssl x509 -req -in "$CERTS_DIR/traefik.csr" -CA "$CERTS_DIR/ca.crt" -CAkey "$CERTS_DIR/ca.key" -CAcreateserial -out "$CERTS_DIR/traefik.crt" -days 825 -sha256 -extensions ext -extfile "$CERTS_DIR/traefik.cnf"

# Auth service server certificate
openssl genrsa -out "$CERTS_DIR/auth.key" 2048
openssl req -new -key "$CERTS_DIR/auth.key" -out "$CERTS_DIR/auth.csr" -subj "/CN=gk-kafka-auth"
openssl x509 -req -in "$CERTS_DIR/auth.csr" -CA "$CERTS_DIR/ca.crt" -CAkey "$CERTS_DIR/ca.key" -CAcreateserial -out "$CERTS_DIR/auth.crt" -days 825 -sha256

# Client certificate
openssl genrsa -out "$CERTS_DIR/client.key" 2048
openssl req -new -key "$CERTS_DIR/client.key" -out "$CERTS_DIR/client.csr" -subj "/CN=gk-kafka-client"
openssl x509 -req -in "$CERTS_DIR/client.csr" -CA "$CERTS_DIR/ca.crt" -CAkey "$CERTS_DIR/ca.key" -CAcreateserial -out "$CERTS_DIR/client.crt" -days 825 -sha256

# Cleanup intermediate files
rm "$CERTS_DIR"/*.csr "$CERTS_DIR"/*.cnf "$CERTS_DIR"/ca.srl 2>/dev/null || true

# Distribute certificates
cp "$CERTS_DIR/traefik.crt" "$TRAEFIK_DIR/cert.pem"
cp "$CERTS_DIR/traefik.key" "$TRAEFIK_DIR/key.pem"

cp "$CERTS_DIR/ca.crt" "$AUTH_CERT_DIR/"
cp "$CERTS_DIR/auth.crt" "$AUTH_CERT_DIR/server.crt"
cp "$CERTS_DIR/auth.key" "$AUTH_CERT_DIR/server.key"

cp "$CERTS_DIR/ca.crt" "$CLIENT_CERT_DIR/"
cp "$CERTS_DIR/client.crt" "$CLIENT_CERT_DIR/client.crt"
cp "$CERTS_DIR/client.key" "$CLIENT_CERT_DIR/client.key"

echo "Certificates generated in $CERTS_DIR and copied to service repos and traefik"