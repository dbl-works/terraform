#!/usr/bin/env bash
set -euo pipefail

umask 077

if [[ $# -lt 3 || $# -gt 4 ]]; then
  echo "Usage: $0 <domain-pattern> <ca-key-file> <ca-certificate-file> [output-directory]" >&2
  exit 1
fi

CERTIFICATE_COMMON_NAME=$1
CA_PRIVATE_KEY_FILE=$2
CA_CERTIFICATE_FILE=$3
CERTS_DIR=${4:-mtls_certs}
LEAF_VALIDITY_DAYS=${MTLS_LEAF_VALIDITY_DAYS:-730}

if [[ ! $LEAF_VALIDITY_DAYS =~ ^[1-9][0-9]*$ ]]; then
  echo "MTLS_LEAF_VALIDITY_DAYS must be a positive integer." >&2
  exit 1
fi

if [[ ! -f $CA_PRIVATE_KEY_FILE || ! -f $CA_CERTIFICATE_FILE ]]; then
  echo "The CA private key and certificate files must both exist." >&2
  exit 1
fi

if [[ -z ${MTLS_CA_PASSPHRASE:-} ]]; then
  if [[ ! -t 0 ]]; then
    echo "MTLS_CA_PASSPHRASE must be set when running non-interactively." >&2
    exit 1
  fi

  read -r -s -p "Root CA passphrase: " MTLS_CA_PASSPHRASE
  echo

  if [[ -z $MTLS_CA_PASSPHRASE ]]; then
    echo "The root CA passphrase must not be empty." >&2
    exit 1
  fi

  export MTLS_CA_PASSPHRASE
fi

openssl pkey -in "$CA_PRIVATE_KEY_FILE" -passin env:MTLS_CA_PASSPHRASE -noout
openssl x509 -in "$CA_CERTIFICATE_FILE" -noout

leaf_validity_seconds=$((LEAF_VALIDITY_DAYS * 86400))
if ! openssl x509 -checkend "$leaf_validity_seconds" -noout -in "$CA_CERTIFICATE_FILE"; then
  echo "The CA certificate expires before the requested leaf certificate. Rotate the CA first." >&2
  exit 1
fi

mkdir -p "$CERTS_DIR"

echo "Generating a new Cloudflare Authenticated Origin Pulls leaf certificate..."
openssl req -new -nodes -newkey rsa:4096 -keyout "$CERTS_DIR/cert.key" -out "$CERTS_DIR/cert.csr" -subj "/C=US/ST=State/L=City/O=Company/CN=$CERTIFICATE_COMMON_NAME"

cat > "$CERTS_DIR/cert.v3.ext" <<'EOF'
basicConstraints=CA:FALSE
keyUsage=critical,digitalSignature
extendedKeyUsage=clientAuth
EOF

openssl x509 -req \
  -in "$CERTS_DIR/cert.csr" \
  -CA "$CA_CERTIFICATE_FILE" \
  -CAkey "$CA_PRIVATE_KEY_FILE" \
  -passin env:MTLS_CA_PASSPHRASE \
  -CAcreateserial \
  -out "$CERTS_DIR/cert.crt" \
  -days "$LEAF_VALIDITY_DAYS" \
  -sha256 \
  -extfile "$CERTS_DIR/cert.v3.ext"

openssl verify -CAfile "$CA_CERTIFICATE_FILE" "$CERTS_DIR/cert.crt"

echo "Leaf certificate written to '$CERTS_DIR/cert.crt'."
echo "Leaf private key written to '$CERTS_DIR/cert.key'."
