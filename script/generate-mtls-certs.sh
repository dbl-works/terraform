#!/usr/bin/env bash
set -euo pipefail

# Private keys created by this script must only be readable by their owner.
umask 077

# This script generates a custom root CA and a leaf certificate
# to be used for Cloudflare Authenticated Origin Pulls (mTLS).
#
# Usage: ./generate-mtls-certs.sh [domain-pattern]
#   e.g. ./generate-mtls-certs.sh "*.my-page.com"

CERTIFICATE_COMMON_NAME=${1:-*.my-page.com}
CERTS_DIR=${MTLS_CERTS_DIR:-mtls_certs}

if [[ -z ${MTLS_CA_PASSPHRASE:-} ]]; then
  if [[ ! -t 0 ]]; then
    echo "MTLS_CA_PASSPHRASE must be set when running non-interactively." >&2
    exit 1
  fi

  read -r -s -p "Root CA passphrase: " MTLS_CA_PASSPHRASE
  echo
  read -r -s -p "Confirm root CA passphrase: " passphrase_confirmation
  echo

  if [[ -z $MTLS_CA_PASSPHRASE || $MTLS_CA_PASSPHRASE != "$passphrase_confirmation" ]]; then
    echo "The root CA passphrases must be non-empty and match." >&2
    exit 1
  fi

  export MTLS_CA_PASSPHRASE
fi

echo "==========================================================="
echo "Generating Certificates for mTLS (Authenticated Origin Pulls)"
echo "Domain Pattern: $CERTIFICATE_COMMON_NAME"
echo "==========================================================="

mkdir -p "$CERTS_DIR"
cd "$CERTS_DIR"

echo "1. Generating encrypted 4096-bit RSA private key for the Root CA..."
openssl genrsa -aes256 -passout env:MTLS_CA_PASSPHRASE -out rootca.key 4096

echo "2. Creating the CA root certificate..."
openssl req -x509 -new -key rootca.key -passin env:MTLS_CA_PASSPHRASE -sha256 -days 1826 -out rootca.crt -subj "/C=US/ST=State/L=City/O=Company/CN=AOP-Root-CA"

echo "3. Creating a Certificate Signing Request (CSR) for the hostname..."
openssl req -new -nodes -newkey rsa:4096 -keyout cert.key -out cert.csr -subj "/C=US/ST=State/L=City/O=Company/CN=$CERTIFICATE_COMMON_NAME"

echo "4. Creating extensions file..."
cat > cert.v3.ext << 'EOF'
basicConstraints=CA:FALSE
EOF

echo "5. Signing the certificate using the Root CA..."
openssl x509 -req -in cert.csr -CA rootca.crt -CAkey rootca.key -passin env:MTLS_CA_PASSPHRASE -CAcreateserial -out cert.crt -days 730 -sha256 -extfile ./cert.v3.ext

echo "==========================================================="
echo "Done! Certificates generated in the '$CERTS_DIR' directory:"
echo " - rootca.crt: Upload this to AWS (alb_mtls_ca_certificates_pem)"
echo " - cert.crt:   Upload this to Cloudflare (authenticated_origin_pull.certificate)"
echo " - cert.key:   Upload this to Cloudflare (authenticated_origin_pull.private_key)"
echo " - rootca.key: Store this encrypted CA key in the restricted Terraform vault"
echo "==========================================================="
echo ""
echo "Move the generated files to their documented secure locations before referencing them from Terraform."
echo "==========================================================="
