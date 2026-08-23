#!/usr/bin/env bash
#
# Rotate Cloudflare Authenticated Origin Pulls (AOP) leaf certificates.
#
# Designed to run unattended from a scheduled GitHub Actions workflow. For
# each configured zone independently: if the current leaf expires within the
# rotation threshold, issue a replacement from the protected root CA held in
# AWS Secrets Manager, merge it back into the vault document, and converge
# one Terraform root. Zones whose leaf is still healthy are left untouched,
# so a rotation is always a no-op until it is actually due.
#
# The root CA is deliberately *not* rotated here — root rotation is a manual,
# overlapping operation. Instead the run fails loudly once the CA approaches
# its own expiry, which surfaces as a red scheduled workflow. Because a leaf
# may never outlive its issuer, issuance itself is refused once the CA has
# less time left than MTLS_LEAF_VALIDITY_DAYS — the same moment the
# MTLS_CA_MIN_REMAINING_YEARS alarm starts firing.
#
# Secret handling: every value lives in a 0700 mktemp directory that a trap
# removes on any exit, reaches openssl through files or `-passin env:`, and is
# never echoed. Do not add `set -x` to this script.
#
# Usage:
#   script/mtls-rotate-leaves.sh                                  # rotate if due
#   script/mtls-rotate-leaves.sh --check-only                      # report only
#   script/mtls-rotate-leaves.sh --check-only --vault-file FIXTURE # tests
#
# Environment:
#   MTLS_ZONES                    Required. Comma-separated `slug=common-name`
#                                 pairs, e.g. "production=example.com" or
#                                 "production=example.com,staging=staging.example.com".
#                                 The slug names the vault keys and the
#                                 Terraform variables; the common name goes
#                                 into the certificate subject.
#   MTLS_SECRET_ID                Required unless --vault-file. Secrets Manager
#                                 secret holding the vault document.
#   MTLS_TERRAFORM_ROOT           Required in rotate mode. The ONLY Terraform
#                                 root this script may init/plan/apply.
#   MTLS_VAULT_KEY_PREFIX         Vault key prefix. Default "cloudflare_aop_".
#                                 Letters, digits, underscores, hyphens only.
#   MTLS_ROTATION_CHECK_ONLY      Env equivalent of --check-only: "1", "true" or
#                                 "yes" to only report; "0", "false", "no" or
#                                 unset to rotate. Any other value is an error
#                                 rather than a silent real rotation.
#   MTLS_ROTATION_THRESHOLD_DAYS  Rotate a leaf with less than this left. Default 60.
#   MTLS_LEAF_VALIDITY_DAYS       Validity of a freshly issued leaf. Default 730.
#   MTLS_CA_MIN_REMAINING_YEARS   Fail the run once the CA has less than this
#                                 left. Default 2.
#   MTLS_TFVARS_PATH              Rendered tfvars file (removed by the exit
#                                 trap). Default
#                                 "$MTLS_TERRAFORM_ROOT/aop.auto.tfvars.json".
#   MTLS_AWS_PROFILE              Local AWS profile. No default: unset means
#                                 ambient credentials. Ignored when CI is set.
#   MTLS_CERT_SUBJECT_BASE        Certificate subject prefix, passed through to
#                                 rotate-mtls-certificates.sh.
#
# Required vault keys (default prefix, MTLS_ZONES="production=example.com"):
#   cloudflare_aop_ca_private_key_pem
#   cloudflare_aop_ca_private_key_passphrase
#   cloudflare_aop_ca_certificate_pem
#   cloudflare_aop_production_certificate_pem
#   cloudflare_aop_production_private_key_pem

set -euo pipefail
umask 077

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RENDER_SCRIPT="$SCRIPT_DIR/mtls-render-terraform-vars.sh"
ISSUE_SCRIPT="$SCRIPT_DIR/rotate-mtls-certificates.sh"

VAULT_SECRET_ID="${MTLS_SECRET_ID:-}"
VAULT_KEY_PREFIX="${MTLS_VAULT_KEY_PREFIX:-cloudflare_aop_}"
TERRAFORM_ROOT="${MTLS_TERRAFORM_ROOT:-}"
ROTATION_THRESHOLD_DAYS="${MTLS_ROTATION_THRESHOLD_DAYS:-60}"
LEAF_VALIDITY_DAYS="${MTLS_LEAF_VALIDITY_DAYS:-730}"
CA_MIN_REMAINING_YEARS="${MTLS_CA_MIN_REMAINING_YEARS:-2}"

usage() {
  cat >&2 <<'USAGE'
Usage: script/mtls-rotate-leaves.sh [--check-only] [--vault-file PATH]

  --check-only        Report the rotation decision and exit without issuing
                      certificates, writing the vault, or running Terraform.
  --vault-file PATH   Read the vault document from PATH instead of Secrets
                      Manager. Only permitted together with --check-only.

Environment equivalent: MTLS_ROTATION_CHECK_ONLY=1|true|yes behaves like
--check-only; 0|false|no or unset rotates. Any other value is rejected.
USAGE
  exit 1
}

# An unrecognised value must never fall through to a real rotation.
case "$(printf '%s' "${MTLS_ROTATION_CHECK_ONLY:-0}" | tr '[:upper:]' '[:lower:]')" in
  1|true|yes) check_only=1 ;;
  0|false|no|"") check_only=0 ;;
  *)
    echo "Error: MTLS_ROTATION_CHECK_ONLY must be one of 1/true/yes or 0/false/no" >&2
    exit 1
    ;;
esac

vault_fixture=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check-only)
      check_only=1
      shift
      ;;
    --vault-file)
      [[ $# -ge 2 ]] || { echo "Error: --vault-file requires a path" >&2; usage; }
      vault_fixture="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      usage
      ;;
  esac
done

# A fixture vault is never in sync with Secrets Manager, so allowing it to
# drive a real rotation would publish test material to the edge.
if [[ -n "$vault_fixture" && "$check_only" != 1 ]]; then
  echo "Error: --vault-file is only supported together with --check-only" >&2
  exit 1
fi

for numeric_setting in ROTATION_THRESHOLD_DAYS LEAF_VALIDITY_DAYS CA_MIN_REMAINING_YEARS; do
  if [[ ! "${!numeric_setting}" =~ ^[1-9][0-9]*$ ]]; then
    echo "Error: MTLS_${numeric_setting} must be a positive integer" >&2
    exit 1
  fi
done

# The prefix is interpolated literally into the jq projection filter built by
# mtls-render-terraform-vars.sh, so it is constrained to the same characters
# the vault keys use.
[[ "$VAULT_KEY_PREFIX" =~ ^[A-Za-z0-9_-]*$ ]] || {
  echo "Error: MTLS_VAULT_KEY_PREFIX may only contain letters, digits, underscores and hyphens" >&2
  exit 1
}

[[ -n "${MTLS_ZONES:-}" ]] || {
  echo "Error: MTLS_ZONES is required (e.g. \"production=example.com\")" >&2
  exit 1
}

# Only the first line of MTLS_ZONES would survive the read below, so a value
# spanning several lines (e.g. a YAML block scalar) has to fail loudly rather
# than silently dropping every zone after the first.
[[ ! "$MTLS_ZONES" =~ [[:space:]] ]] || {
  echo "Error: MTLS_ZONES must not contain whitespace or newlines" >&2
  exit 1
}

ZONE_SLUGS=()
ZONE_COMMON_NAMES=()
IFS=',' read -r -a zone_entries <<< "$MTLS_ZONES"
for entry in "${zone_entries[@]}"; do
  slug="${entry%%=*}"
  common_name="${entry#*=}"
  if [[ -z "$slug" || -z "$common_name" || "$entry" != *=* ]]; then
    echo "Error: MTLS_ZONES entries must look like slug=common-name" >&2
    exit 1
  fi
  [[ "$slug" =~ ^[A-Za-z0-9_-]+$ ]] || { echo "Error: invalid zone slug in MTLS_ZONES: $slug" >&2; exit 1; }
  # The common name ends up in an openssl -subj argument, where a stray slash
  # or equals sign would add attacker-chosen subject fields.
  [[ "$common_name" =~ ^(\*\.)?[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?(\.[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?)*$ ]] || {
    echo "Error: invalid zone common name in MTLS_ZONES: $common_name" >&2
    exit 1
  }
  ZONE_SLUGS+=("$slug")
  ZONE_COMMON_NAMES+=("$common_name")
done

for required_binary in jq openssl; do
  command -v "$required_binary" >/dev/null 2>&1 || {
    echo "Error: $required_binary is required but not found on PATH" >&2
    exit 1
  }
done

if [[ -z "$vault_fixture" ]]; then
  [[ -n "$VAULT_SECRET_ID" ]] || { echo "Error: MTLS_SECRET_ID is required" >&2; exit 1; }
fi

if [[ "$check_only" != 1 ]]; then
  [[ -n "$TERRAFORM_ROOT" ]] || { echo "Error: MTLS_TERRAFORM_ROOT is required" >&2; exit 1; }
  [[ -d "$TERRAFORM_ROOT" ]] || { echo "Error: MTLS_TERRAFORM_ROOT is not a directory: $TERRAFORM_ROOT" >&2; exit 1; }
  TERRAFORM_ROOT="$(cd "$TERRAFORM_ROOT" && pwd)"

  [[ -x "$RENDER_SCRIPT" ]] || { echo "Error: helper script not found: $RENDER_SCRIPT" >&2; exit 1; }
  [[ -x "$ISSUE_SCRIPT" ]] || { echo "Error: helper script not found: $ISSUE_SCRIPT" >&2; exit 1; }

  for required_binary in aws terraform; do
    command -v "$required_binary" >/dev/null 2>&1 || {
      echo "Error: $required_binary is required but not found on PATH" >&2
      exit 1
    }
  done

  # CI authenticates through the workflow's ambient credentials; locally the
  # vault may live behind a named profile.
  if [[ -z "${CI:-}" && -n "${MTLS_AWS_PROFILE:-}" ]]; then
    export AWS_PROFILE="$MTLS_AWS_PROFILE"
  fi
fi

TFVARS_PATH="${MTLS_TFVARS_PATH:-$TERRAFORM_ROOT/aop.auto.tfvars.json}"
PLAN_PATH="$TERRAFORM_ROOT/rotation.tfplan"

work_dir="$(mktemp -d)"
chmod 700 "$work_dir"
cleanup() {
  # The saved plan and the rendered tfvars both embed leaf private keys, so
  # neither may survive the run — including when apply fails.
  if [[ "$check_only" != 1 ]]; then
    rm -f "$PLAN_PATH" "$TFVARS_PATH"
  fi
  rm -rf "$work_dir"
}
trap cleanup EXIT INT TERM

vault_file="$work_dir/vault.json"

if [[ -n "$vault_fixture" ]]; then
  [[ -f "$vault_fixture" ]] || { echo "Error: vault file not found: $vault_fixture" >&2; exit 1; }
  cp "$vault_fixture" "$vault_file"
else
  aws secretsmanager get-secret-value \
    --secret-id "$VAULT_SECRET_ID" \
    --query SecretString \
    --output text > "$vault_file"
fi

chmod 600 "$vault_file"

# jq's parse errors can quote fragments of the document, so its diagnostics
# never reach the log.
if ! jq -e 'type == "object"' "$vault_file" >/dev/null 2>/dev/null; then
  echo "Error: vault document is not a valid JSON object" >&2
  exit 1
fi

ca_private_key_key="${VAULT_KEY_PREFIX}ca_private_key_pem"
ca_passphrase_key="${VAULT_KEY_PREFIX}ca_private_key_passphrase"
ca_certificate_key="${VAULT_KEY_PREFIX}ca_certificate_pem"

required_keys=("$ca_private_key_key" "$ca_passphrase_key" "$ca_certificate_key")
for slug in "${ZONE_SLUGS[@]}"; do
  required_keys+=("${VAULT_KEY_PREFIX}${slug}_certificate_pem" "${VAULT_KEY_PREFIX}${slug}_private_key_pem")
done

for key in "${required_keys[@]}"; do
  if ! jq -e --arg k "$key" \
    'has($k) and (.[$k] | type == "string") and (.[$k] | length > 0)' \
    "$vault_file" >/dev/null 2>/dev/null; then
    echo "Error: missing or empty required vault key: $key" >&2
    exit 1
  fi
done

jq -r --arg k "$ca_private_key_key" '.[$k]' "$vault_file" > "$work_dir/rootca.key"
jq -r --arg k "$ca_certificate_key" '.[$k]' "$vault_file" > "$work_dir/rootca.crt"
MTLS_CA_PASSPHRASE="$(jq -r --arg k "$ca_passphrase_key" '.[$k]' "$vault_file")"
export MTLS_CA_PASSPHRASE

rotation_threshold_seconds=$((ROTATION_THRESHOLD_DAYS * 86400))

rotation_required=false
for slug in "${ZONE_SLUGS[@]}"; do
  jq -r --arg k "${VAULT_KEY_PREFIX}${slug}_certificate_pem" '.[$k]' "$vault_file" > "$work_dir/$slug-current.crt"
  if ! openssl x509 -checkend "$rotation_threshold_seconds" -noout -in "$work_dir/$slug-current.crt" >/dev/null; then
    echo "$slug leaf expires within $ROTATION_THRESHOLD_DAYS days"
    rotation_required=true
  fi
done

# Root rotation is a manual, overlapping operation; the run only escalates.
# Evaluated before the check-only exit so a manual check also reports CA
# health and so the milestone ladder is testable without touching AWS.
ca_ladder_days=(90 180 365 $((CA_MIN_REMAINING_YEARS * 365)))
ca_expiry_alert=false
previous_rung=0
for rung_days in "${ca_ladder_days[@]}"; do
  # Keep the ladder strictly ascending even for unusual thresholds.
  (( rung_days > previous_rung )) || continue
  previous_rung="$rung_days"
  if ! openssl x509 -checkend $((rung_days * 86400)) -noout -in "$work_dir/rootca.crt" >/dev/null; then
    echo "::error::mTLS root CA expires within $rung_days days"
    ca_expiry_alert=true
    break
  fi
done

if [[ "$check_only" == 1 ]]; then
  if [[ "$rotation_required" == true ]]; then
    echo "rotation-required"
  else
    echo "rotation-not-required"
  fi
  if [[ "$ca_expiry_alert" == true ]]; then
    exit 1
  fi
  exit 0
fi

if [[ "$rotation_required" == false ]]; then
  echo "rotation-not-required"
fi

for index in "${!ZONE_SLUGS[@]}"; do
  slug="${ZONE_SLUGS[$index]}"
  common_name="${ZONE_COMMON_NAMES[$index]}"

  if openssl x509 -checkend "$rotation_threshold_seconds" -noout -in "$work_dir/$slug-current.crt" >/dev/null; then
    continue
  fi

  echo "issuing a replacement leaf for $common_name"

  # Reuse the single-leaf issuing helper rather than duplicating its openssl
  # logic. It refuses to mint a leaf that would outlive the CA.
  MTLS_LEAF_VALIDITY_DAYS="$LEAF_VALIDITY_DAYS" \
    "$ISSUE_SCRIPT" "$common_name" \
    "$work_dir/rootca.key" "$work_dir/rootca.crt" "$work_dir/$slug-new"

  openssl x509 -purpose -noout -in "$work_dir/$slug-new/cert.crt" | grep -q 'SSL client : Yes'

  # Merge into the full vault document so every unrelated secret survives.
  jq --arg cert_key "${VAULT_KEY_PREFIX}${slug}_certificate_pem" \
    --arg key_key "${VAULT_KEY_PREFIX}${slug}_private_key_pem" \
    --rawfile cert "$work_dir/$slug-new/cert.crt" \
    --rawfile key "$work_dir/$slug-new/cert.key" \
    '. + {($cert_key): $cert, ($key_key): $key}' \
    "$vault_file" > "$work_dir/next.json"
  mv "$work_dir/next.json" "$vault_file"
  chmod 600 "$vault_file"
done

# The passphrase has no further use past this point; dropping it from the
# environment before any aws/terraform invocation narrows its blast radius.
unset MTLS_CA_PASSPHRASE

if [[ "$rotation_required" == true ]]; then
  # `--secret-string file://` keeps the document off the process arguments.
  aws secretsmanager put-secret-value \
    --secret-id "$VAULT_SECRET_ID" \
    --secret-string "file://$vault_file" \
    --query 'VersionId' \
    --output text
fi

# Convergence is unconditional: a run whose apply failed after the vault was
# already written would otherwise see a fresh leaf, report
# rotation-not-required and leave the old certificate on the edge forever.
# With healthy leaves this is a zero-diff no-op.
"$RENDER_SCRIPT" "$vault_file" "$TFVARS_PATH"

# A backend that pins a local profile must fall back to the environment's
# credentials on CI.
terraform_init_args=(-input=false)
if [[ -n "${CI:-}" ]]; then
  terraform_init_args+=(-backend-config=profile=)
fi

terraform -chdir="$TERRAFORM_ROOT" init "${terraform_init_args[@]}"
terraform -chdir="$TERRAFORM_ROOT" plan -input=false --lock-timeout=300s -out=rotation.tfplan
terraform -chdir="$TERRAFORM_ROOT" apply -input=false --lock-timeout=300s -auto-approve rotation.tfplan

# Signals to the workflow that the edge actually converged, so a verification
# step only runs when there is something worth verifying.
if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  echo "converged=true" >> "$GITHUB_OUTPUT"
fi

if [[ "$rotation_required" == true ]]; then
  echo "rotation-complete"
else
  echo "edge-converged"
fi

if [[ "$ca_expiry_alert" == true ]]; then
  exit 1
fi
