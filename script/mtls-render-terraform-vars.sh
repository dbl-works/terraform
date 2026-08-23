#!/usr/bin/env bash
#
# Render Terraform tfvars JSON from a full Secrets Manager vault document.
#
# Projects only the Authenticated Origin Pulls (AOP) fields the Cloudflare
# module needs, renaming them to their Terraform variable names. Every other
# vault key (database passwords, API tokens, ...) is dropped. Non-interactive
# and silent about secret values, so it is safe to call from an unattended
# rotation workflow and from other ops scripts.
#
# Usage:
#   script/mtls-render-terraform-vars.sh <input-vault-json> <output-tfvars-json>
#
# Environment:
#   MTLS_ZONES              Required. Comma-separated zone slugs, e.g.
#                           "production" or "production,staging". Entries may
#                           carry a "=<common-name>" suffix (as accepted by
#                           mtls-rotate-leaves.sh); the suffix is ignored here,
#                           so both scripts can share one MTLS_ZONES value.
#   MTLS_VAULT_KEY_PREFIX   Vault key prefix. Default "cloudflare_aop_".
#
# Mapping (for MTLS_ZONES="production", default prefix):
#   cloudflare_aop_ca_certificate_pem          -> aop_ca_certificate_pem
#   cloudflare_aop_production_certificate_pem  -> aop_production_certificate_pem
#   cloudflare_aop_production_private_key_pem  -> aop_production_private_key_pem

set -euo pipefail
umask 077

usage() {
  echo "Usage: $0 <input-vault-json> <output-tfvars-json>" >&2
  exit 1
}

[[ $# -eq 2 ]] || usage

INPUT_PATH="$1"
OUTPUT_PATH="$2"

VAULT_KEY_PREFIX="${MTLS_VAULT_KEY_PREFIX:-cloudflare_aop_}"

command -v jq >/dev/null 2>&1 || { echo "Error: jq is required but not found on PATH" >&2; exit 1; }
[[ -f "$INPUT_PATH" ]] || { echo "Error: input file not found: $INPUT_PATH" >&2; exit 1; }

[[ -n "${MTLS_ZONES:-}" ]] || { echo "Error: MTLS_ZONES is required (e.g. \"production\" or \"production,staging\")" >&2; exit 1; }

ZONE_SLUGS=()
IFS=',' read -r -a zone_entries <<< "$MTLS_ZONES"
for entry in "${zone_entries[@]}"; do
  # Tolerate the "slug=common-name" form used by mtls-rotate-leaves.sh.
  slug="${entry%%=*}"
  slug="${slug//[[:space:]]/}"
  [[ -n "$slug" ]] || { echo "Error: MTLS_ZONES contains an empty zone slug" >&2; exit 1; }
  [[ "$slug" =~ ^[A-Za-z0-9_-]+$ ]] || { echo "Error: invalid zone slug in MTLS_ZONES: $slug" >&2; exit 1; }
  ZONE_SLUGS+=("$slug")
done

# Never let jq's own error text (which can echo fragments of malformed
# input) reach stdout/stderr — replace it with a generic message.
if ! jq -e 'type == "object"' "$INPUT_PATH" >/dev/null 2>/dev/null; then
  echo "Error: input is not a valid JSON object: $INPUT_PATH" >&2
  exit 1
fi

# Allowlist projection: vault key (index i) -> Terraform variable name (index i).
VAULT_KEYS=("${VAULT_KEY_PREFIX}ca_certificate_pem")
TF_KEYS=("aop_ca_certificate_pem")
for slug in "${ZONE_SLUGS[@]}"; do
  VAULT_KEYS+=("${VAULT_KEY_PREFIX}${slug}_certificate_pem" "${VAULT_KEY_PREFIX}${slug}_private_key_pem")
  TF_KEYS+=("aop_${slug}_certificate_pem" "aop_${slug}_private_key_pem")
done

for key in "${VAULT_KEYS[@]}"; do
  if ! jq -e --arg k "$key" \
    'has($k) and (.[$k] | type == "string") and (.[$k] | length > 0)' \
    "$INPUT_PATH" >/dev/null 2>/dev/null; then
    echo "Error: missing or empty required key: $key" >&2
    exit 1
  fi
done

OUTPUT_DIR="$(dirname "$OUTPUT_PATH")"
mkdir -p "$OUTPUT_DIR"

JQ_FILTER='{'
for i in "${!VAULT_KEYS[@]}"; do
  JQ_FILTER+="\"${TF_KEYS[$i]}\": .[\"${VAULT_KEYS[$i]}\"],"
done
JQ_FILTER="${JQ_FILTER%,}}"

TMP_OUTPUT="$(mktemp "$OUTPUT_DIR/.mtls-render-terraform-vars.XXXXXX")"
cleanup() {
  rm -f "$TMP_OUTPUT"
}
trap cleanup EXIT

if ! jq "$JQ_FILTER" "$INPUT_PATH" > "$TMP_OUTPUT" 2>/dev/null; then
  echo "Error: failed to render terraform vars" >&2
  exit 1
fi

chmod 600 "$TMP_OUTPUT"
mv -f "$TMP_OUTPUT" "$OUTPUT_PATH"
chmod 600 "$OUTPUT_PATH"
trap - EXIT
