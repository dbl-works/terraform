#!/usr/bin/env bash
set -e

# This script generates a custom root CA and a leaf certificate
# to be used for Cloudflare Authenticated Origin Pulls (mTLS).
# 
# Usage: ./generate-mtls-certs.sh [domain-pattern]
#   e.g. ./generate-mtls-certs.sh "*.my-page.com"

HOSTNAME=${1:-*.my-page.com}
CERTS_DIR="mtls_certs"

echo "==========================================================="
echo "Generating Certificates for mTLS (Authenticated Origin Pulls)"
echo "Domain Pattern: $HOSTNAME"
echo "==========================================================="

mkdir -p "$CERTS_DIR"
cd "$CERTS_DIR"

echo "1. Generating 4096-bit RSA private key for the Root CA..."
# Use -aes256 locally, but we might want script to be non-interactive
# If you want it secure with passphrase, remove the comments below.
# Here we generate an unencrypted key for easy automated usage if needed, 
# or encrypted if prompted. We will use unencrypted for the root for simplicity in the script,
# but in production, a passphrase-protected key is recommended.
openssl genrsa -out rootca.key 4096

echo "2. Creating the CA root certificate..."
openssl req -x509 -new -nodes -key rootca.key -sha256 -days 1826 -out rootca.crt -subj "/C=US/ST=State/L=City/O=Company/CN=OAP-Root-CA"

echo "3. Creating a Certificate Signing Request (CSR) for the hostname..."
openssl req -new -nodes -newkey rsa:4096 -keyout cert.key -out cert.csr -subj "/C=US/ST=State/L=City/O=Company/CN=$HOSTNAME"

echo "4. Creating extensions file..."
cat > cert.v3.ext << 'EOF'
basicConstraints=CA:FALSE
EOF

echo "5. Signing the certificate using the Root CA..."
openssl x509 -req -in cert.csr -CA rootca.crt -CAkey rootca.key -CAcreateserial -out cert.crt -days 730 -sha256 -extfile ./cert.v3.ext

echo "==========================================================="
echo "Done! Certificates generated in the '$CERTS_DIR' directory:"
echo " - rootca.crt: Upload this to AWS (alb_mtls_ca_certificates_pem)"
echo " - cert.crt:   Upload this to Cloudflare (authenticated_origin_pull.certificate)"
echo " - cert.key:   Upload this to Cloudflare (authenticated_origin_pull.private_key)"
echo "==========================================================="
echo ""
echo "In your Terraform configuration, you can reference these files:"
echo "alb_mtls_ca_certificates_pem = file(\"../script/$CERTS_DIR/rootca.crt\")"
echo "authenticated_origin_pull = {"
echo "  enabled     = true"
echo "  certificate = file(\"../script/$CERTS_DIR/cert.crt\")"
echo "  private_key = file(\"../script/$CERTS_DIR/cert.key\")"
echo "}"
echo "==========================================================="
