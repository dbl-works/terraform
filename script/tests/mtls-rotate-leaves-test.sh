#!/usr/bin/env bash
#
# Behavior test for script/mtls-rotate-leaves.sh
#
# A throwaway CA and leaf certificates are minted locally and fed to the
# script as a fixture vault document. In the check-only cases `aws` and
# `terraform` are shadowed by shims that record their invocation and fail
# loudly, so "the decision path performs no external calls" is an assertion
# rather than a claim. The rotation cases swap in succeeding shims that
# capture the document the script would have uploaded.
#
# Run with: bash script/tests/mtls-rotate-leaves-test.sh

set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_UNDER_TEST="$TEST_DIR/../mtls-rotate-leaves.sh"

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

FAILURES=0

assert() {
  local description="$1"
  local condition="$2"
  if [[ "$condition" -eq 0 ]]; then
    echo "  ok - $description"
  else
    echo "  NOT OK - $description"
    FAILURES=$((FAILURES + 1))
  fi
}

# Portable file-mode check (BSD stat on macOS vs GNU stat on Linux).
file_mode() {
  local path="$1"
  if stat -f %Lp "$path" >/dev/null 2>&1; then
    stat -f %Lp "$path"
  else
    stat -c %a "$path"
  fi
}

export MTLS_ZONES="production=example.com,staging=staging.example.com"
export MTLS_SECRET_ID="my-project/terraform/production"

# ---------------------------------------------------------------------------
# Shims: any external call the script makes must fail loudly and leave a
# trace.
# ---------------------------------------------------------------------------
SHIM_DIR="$WORK_DIR/shims"
EXTERNAL_CALL_MARKER="$WORK_DIR/external-call-was-made"
mkdir -p "$SHIM_DIR"
for shimmed in aws terraform curl; do
  cat > "$SHIM_DIR/$shimmed" <<SHIM
#!/usr/bin/env bash
echo "$shimmed" >> "$EXTERNAL_CALL_MARKER"
echo "FORBIDDEN EXTERNAL CALL: $shimmed \$*" >&2
exit 97
SHIM
  chmod 700 "$SHIM_DIR/$shimmed"
done
export PATH="$SHIM_DIR:$PATH"

# The script's own temp directories land here, so cleanup is observable.
SCRIPT_TMPDIR="$WORK_DIR/script-tmp"
mkdir -p "$SCRIPT_TMPDIR"

CA_PASSPHRASE="fixture-passphrase-not-a-real-secret"

# mint_ca <dir> <days>
mint_ca() {
  local dir="$1"
  local days="$2"
  mkdir -p "$dir"
  MTLS_TEST_PASSPHRASE="$CA_PASSPHRASE" openssl genrsa \
    -aes256 -passout env:MTLS_TEST_PASSPHRASE \
    -out "$dir/rootca.key" 2048 >/dev/null 2>&1
  MTLS_TEST_PASSPHRASE="$CA_PASSPHRASE" openssl req -x509 -new \
    -key "$dir/rootca.key" -passin env:MTLS_TEST_PASSPHRASE \
    -sha256 -days "$days" \
    -subj "/C=US/O=Example Test/CN=Example Test CA" \
    -out "$dir/rootca.crt" >/dev/null 2>&1
}

# mint_leaf <ca-dir> <out-dir> <common-name> <days>
mint_leaf() {
  local ca_dir="$1"
  local dir="$2"
  local common_name="$3"
  local days="$4"
  mkdir -p "$dir"
  printf '%s\n' \
    'basicConstraints=CA:FALSE' \
    'keyUsage=critical,digitalSignature' \
    'extendedKeyUsage=clientAuth' > "$dir/client.ext"
  openssl req -new -nodes -newkey rsa:2048 \
    -keyout "$dir/cert.key" -out "$dir/cert.csr" \
    -subj "/C=US/O=Example Test/CN=$common_name" >/dev/null 2>&1
  MTLS_TEST_PASSPHRASE="$CA_PASSPHRASE" openssl x509 -req -in "$dir/cert.csr" \
    -CA "$ca_dir/rootca.crt" -CAkey "$ca_dir/rootca.key" \
    -passin env:MTLS_TEST_PASSPHRASE -CAcreateserial -sha256 -days "$days" \
    -extfile "$dir/client.ext" -out "$dir/cert.crt" >/dev/null 2>&1
}

# build_fixture <name> <ca-days> <production-leaf-days> <staging-leaf-days> -> prints path
build_fixture() {
  local name="$1"
  local ca_days="$2"
  local production_days="$3"
  local staging_days="$4"
  local dir="$WORK_DIR/$name"

  mint_ca "$dir/ca" "$ca_days"
  mint_leaf "$dir/ca" "$dir/production" "example.com" "$production_days"
  mint_leaf "$dir/ca" "$dir/staging" "staging.example.com" "$staging_days"

  jq -n \
    --arg passphrase "$CA_PASSPHRASE" \
    --rawfile ca_key "$dir/ca/rootca.key" \
    --rawfile ca_cert "$dir/ca/rootca.crt" \
    --rawfile production_cert "$dir/production/cert.crt" \
    --rawfile production_key "$dir/production/cert.key" \
    --rawfile staging_cert "$dir/staging/cert.crt" \
    --rawfile staging_key "$dir/staging/cert.key" \
    '{
      unrelated_secret: "fake-decoy-do-not-use",
      cloudflare_aop_ca_private_key_pem: $ca_key,
      cloudflare_aop_ca_private_key_passphrase: $passphrase,
      cloudflare_aop_ca_certificate_pem: $ca_cert,
      cloudflare_aop_production_certificate_pem: $production_cert,
      cloudflare_aop_production_private_key_pem: $production_key,
      cloudflare_aop_staging_certificate_pem: $staging_cert,
      cloudflare_aop_staging_private_key_pem: $staging_key
    }' > "$dir/vault.json"

  echo "$dir/vault.json"
}

# run_check_only <fixture> <log-prefix> -> exit code in RUN_EXIT
run_check_only() {
  local fixture="$1"
  local prefix="$2"
  set +e
  TMPDIR="$SCRIPT_TMPDIR" bash "$SCRIPT_UNDER_TEST" \
    --check-only --vault-file "$fixture" \
    >"$WORK_DIR/$prefix-stdout.log" 2>"$WORK_DIR/$prefix-stderr.log"
  RUN_EXIT=$?
  set -e
}

echo "== mtls-rotate-leaves.sh behavior tests =="

# ---------------------------------------------------------------------------
# Case 1: leaves with 90 days left -> no rotation, no external calls
# ---------------------------------------------------------------------------
echo "-- case 1: 90-day leaves, healthy CA"
FRESH_FIXTURE="$(build_fixture fresh 3650 90 90)"
run_check_only "$FRESH_FIXTURE" fresh

assert "check-only exits 0 for 90-day leaves" $([[ "$RUN_EXIT" -eq 0 ]] && echo 0 || echo 1)
assert "check-only prints rotation-not-required for 90-day leaves" \
  $(grep -qx "rotation-not-required" "$WORK_DIR/fresh-stdout.log" && echo 0 || echo 1)
assert "check-only makes no external calls (aws/terraform/curl)" \
  $([[ ! -f "$EXTERNAL_CALL_MARKER" ]] && echo 0 || echo 1)
assert "check-only leaves no temp directory behind" \
  $([[ -z "$(ls -A "$SCRIPT_TMPDIR")" ]] && echo 0 || echo 1)
assert "check-only never prints the CA passphrase" \
  $(grep -q "$CA_PASSPHRASE" "$WORK_DIR/fresh-stdout.log" "$WORK_DIR/fresh-stderr.log" && echo 1 || echo 0)
assert "check-only never prints PEM material" \
  $(grep -q "BEGIN " "$WORK_DIR/fresh-stdout.log" "$WORK_DIR/fresh-stderr.log" && echo 1 || echo 0)
assert "check-only leaves the fixture vault document unmodified" \
  $(jq -e '.unrelated_secret == "fake-decoy-do-not-use"' "$FRESH_FIXTURE" >/dev/null 2>&1 && echo 0 || echo 1)

# ---------------------------------------------------------------------------
# Case 2: one leaf with 30 days left -> rotation required, still no calls
# ---------------------------------------------------------------------------
echo "-- case 2: 30-day production leaf, healthy CA"
EXPIRING_FIXTURE="$(build_fixture expiring 3650 30 90)"
run_check_only "$EXPIRING_FIXTURE" expiring

assert "check-only exits 0 for a 30-day leaf" $([[ "$RUN_EXIT" -eq 0 ]] && echo 0 || echo 1)
assert "check-only prints rotation-required for a 30-day leaf" \
  $(grep -qx "rotation-required" "$WORK_DIR/expiring-stdout.log" && echo 0 || echo 1)
assert "check-only names the expiring zone and the threshold" \
  $(grep -qx "production leaf expires within 60 days" "$WORK_DIR/expiring-stdout.log" && echo 0 || echo 1)
assert "check-only still makes no external calls" \
  $([[ ! -f "$EXTERNAL_CALL_MARKER" ]] && echo 0 || echo 1)
assert "check-only does not issue a new certificate" \
  $(grep -q "BEGIN CERTIFICATE" "$WORK_DIR/expiring-stdout.log" && echo 1 || echo 0)

# ---------------------------------------------------------------------------
# Case 3: CA under the minimum remaining lifetime -> loud failure, leaf
# decision still reported
# ---------------------------------------------------------------------------
echo "-- case 3: CA with 500 days left"
AGING_CA_FIXTURE="$(build_fixture aging-ca 500 365 365)"
run_check_only "$AGING_CA_FIXTURE" aging-ca

assert "CA under two years fails the run" $([[ "$RUN_EXIT" -ne 0 ]] && echo 0 || echo 1)
assert "CA warning names the outermost ladder rung (730 days)" \
  $(grep -q "expires within 730 days" "$WORK_DIR/aging-ca-stdout.log" "$WORK_DIR/aging-ca-stderr.log" && echo 0 || echo 1)
assert "leaf decision is still reported alongside the CA failure" \
  $(grep -qx "rotation-not-required" "$WORK_DIR/aging-ca-stdout.log" && echo 0 || echo 1)
assert "CA health check makes no external calls" \
  $([[ ! -f "$EXTERNAL_CALL_MARKER" ]] && echo 0 || echo 1)

echo "-- case 3b: CA with 60 days left hits the tightest rung"
DYING_CA_FIXTURE="$(build_fixture dying-ca 60 365 365)"
run_check_only "$DYING_CA_FIXTURE" dying-ca

assert "CA under 90 days fails the run" $([[ "$RUN_EXIT" -ne 0 ]] && echo 0 || echo 1)
assert "CA warning names the 90-day rung" \
  $(grep -q "expires within 90 days" "$WORK_DIR/dying-ca-stdout.log" && echo 0 || echo 1)
assert "only one ladder rung is reported" \
  $([[ "$(grep -c "root CA expires within" "$WORK_DIR/dying-ca-stdout.log")" -eq 1 ]] && echo 0 || echo 1)

# ---------------------------------------------------------------------------
# Case 4: a fixture vault may never be used for a real rotation
# ---------------------------------------------------------------------------
echo "-- case 4: --vault-file requires --check-only"
set +e
TMPDIR="$SCRIPT_TMPDIR" bash "$SCRIPT_UNDER_TEST" --vault-file "$FRESH_FIXTURE" \
  >"$WORK_DIR/no-check-stdout.log" 2>"$WORK_DIR/no-check-stderr.log"
NO_CHECK_EXIT=$?
set -e

assert "--vault-file without --check-only is rejected" $([[ "$NO_CHECK_EXIT" -ne 0 ]] && echo 0 || echo 1)
assert "rejection explains the constraint" \
  $(grep -q -- "--check-only" "$WORK_DIR/no-check-stderr.log" && echo 0 || echo 1)
assert "rejected run makes no external calls" \
  $([[ ! -f "$EXTERNAL_CALL_MARKER" ]] && echo 0 || echo 1)

# ---------------------------------------------------------------------------
# Case 5: an incomplete vault document is rejected before anything happens
# ---------------------------------------------------------------------------
echo "-- case 5: incomplete vault document"
INCOMPLETE_FIXTURE="$WORK_DIR/incomplete-vault.json"
jq 'del(.cloudflare_aop_staging_certificate_pem)' "$FRESH_FIXTURE" > "$INCOMPLETE_FIXTURE"
run_check_only "$INCOMPLETE_FIXTURE" incomplete

assert "incomplete vault document is rejected" $([[ "$RUN_EXIT" -ne 0 ]] && echo 0 || echo 1)
assert "rejection names the missing key" \
  $(grep -q "cloudflare_aop_staging_certificate_pem" "$WORK_DIR/incomplete-stderr.log" && echo 0 || echo 1)
assert "rejection leaks no PEM material" \
  $(grep -q "BEGIN " "$WORK_DIR/incomplete-stdout.log" "$WORK_DIR/incomplete-stderr.log" && echo 1 || echo 0)

# ---------------------------------------------------------------------------
# Case 6: rotate mode requires a configuration it can actually converge
# ---------------------------------------------------------------------------
echo "-- case 6: rotate mode configuration guards"
set +e
TMPDIR="$SCRIPT_TMPDIR" env -u MTLS_TERRAFORM_ROOT bash "$SCRIPT_UNDER_TEST" \
  >"$WORK_DIR/no-root-stdout.log" 2>"$WORK_DIR/no-root-stderr.log"
NO_ROOT_EXIT=$?
TMPDIR="$SCRIPT_TMPDIR" env -u MTLS_SECRET_ID MTLS_TERRAFORM_ROOT="$WORK_DIR" bash "$SCRIPT_UNDER_TEST" \
  >"$WORK_DIR/no-secret-stdout.log" 2>"$WORK_DIR/no-secret-stderr.log"
NO_SECRET_EXIT=$?
set -e

assert "rotate mode without MTLS_TERRAFORM_ROOT is rejected" $([[ "$NO_ROOT_EXIT" -ne 0 ]] && echo 0 || echo 1)
assert "rejection names MTLS_TERRAFORM_ROOT" \
  $(grep -q "MTLS_TERRAFORM_ROOT" "$WORK_DIR/no-root-stderr.log" && echo 0 || echo 1)
assert "rotate mode without MTLS_SECRET_ID is rejected" $([[ "$NO_SECRET_EXIT" -ne 0 ]] && echo 0 || echo 1)
assert "rejection names MTLS_SECRET_ID" \
  $(grep -q "MTLS_SECRET_ID" "$WORK_DIR/no-secret-stderr.log" && echo 0 || echo 1)
assert "configuration guards make no external calls" \
  $([[ ! -f "$EXTERNAL_CALL_MARKER" ]] && echo 0 || echo 1)

# ---------------------------------------------------------------------------
# Case 7: full rotation path against succeeding aws/terraform shims
# ---------------------------------------------------------------------------
echo "-- case 7: rotation path (production expiring, staging healthy)"
ROTATION_FIXTURE="$(build_fixture rotation 3650 30 700)"

FAKE_TERRAFORM_ROOT="$WORK_DIR/terraform-root"
mkdir -p "$FAKE_TERRAFORM_ROOT"

UPLOAD_CAPTURE="$WORK_DIR/uploaded-vault.json"
AWS_ARGS_LOG="$WORK_DIR/aws-args.log"
TERRAFORM_ARGS_LOG="$WORK_DIR/terraform-args.log"
export MTLS_TEST_VAULT_SOURCE="$ROTATION_FIXTURE"
export MTLS_TEST_UPLOAD_CAPTURE="$UPLOAD_CAPTURE"
export MTLS_TEST_AWS_LOG="$AWS_ARGS_LOG"
export MTLS_TEST_TERRAFORM_LOG="$TERRAFORM_ARGS_LOG"

SUCCESS_SHIM_DIR="$WORK_DIR/success-shims"
mkdir -p "$SUCCESS_SHIM_DIR"
cat > "$SUCCESS_SHIM_DIR/aws" <<'SHIM'
#!/usr/bin/env bash
set -euo pipefail
echo "$*" >> "$MTLS_TEST_AWS_LOG"
case "${2:-}" in
  get-secret-value)
    cat "$MTLS_TEST_VAULT_SOURCE"
    ;;
  put-secret-value)
    for arg in "$@"; do
      case "$arg" in
        file://*) cp "${arg#file://}" "$MTLS_TEST_UPLOAD_CAPTURE" ;;
      esac
    done
    echo "fixture-version-id"
    ;;
  *)
    echo "unexpected aws call: $*" >&2
    exit 1
    ;;
esac
SHIM
cat > "$SUCCESS_SHIM_DIR/terraform" <<'SHIM'
#!/usr/bin/env bash
set -euo pipefail
echo "$*" >> "$MTLS_TEST_TERRAFORM_LOG"
SHIM
chmod 700 "$SUCCESS_SHIM_DIR/aws" "$SUCCESS_SHIM_DIR/terraform"

GITHUB_OUTPUT_FILE="$WORK_DIR/github-output.txt"
: > "$GITHUB_OUTPUT_FILE"

# CI=1 exercises the -backend-config=profile= override path (mirrors the
# GitHub Actions environment); case 8 below runs with CI unset so both
# branches of that conditional stay covered.
set +e
TMPDIR="$SCRIPT_TMPDIR" PATH="$SUCCESS_SHIM_DIR:$PATH" CI=1 \
  GITHUB_OUTPUT="$GITHUB_OUTPUT_FILE" \
  MTLS_TERRAFORM_ROOT="$FAKE_TERRAFORM_ROOT" \
  bash "$SCRIPT_UNDER_TEST" \
  >"$WORK_DIR/rotation-stdout.log" 2>"$WORK_DIR/rotation-stderr.log"
ROTATION_EXIT=$?
set -e

assert "rotation run exits 0" $([[ "$ROTATION_EXIT" -eq 0 ]] && echo 0 || echo 1)
assert "rotation run reports rotation-complete" \
  $(grep -qx "rotation-complete" "$WORK_DIR/rotation-stdout.log" && echo 0 || echo 1)
assert "only one leaf is reported as expiring" \
  $([[ "$(grep -c "leaf expires within 60 days" "$WORK_DIR/rotation-stdout.log")" -eq 1 ]] && echo 0 || echo 1)
assert "the expiring zone named is production" \
  $(grep -qx "production leaf expires within 60 days" "$WORK_DIR/rotation-stdout.log" && echo 0 || echo 1)
assert "the reissue names the zone's common name" \
  $(grep -qx "issuing a replacement leaf for example.com" "$WORK_DIR/rotation-stdout.log" && echo 0 || echo 1)
assert "converged=true is written to GITHUB_OUTPUT" \
  $(grep -qx "converged=true" "$GITHUB_OUTPUT_FILE" && echo 0 || echo 1)
assert "an uploaded vault document was captured" $([[ -f "$UPLOAD_CAPTURE" ]] && echo 0 || echo 1)

if [[ -f "$UPLOAD_CAPTURE" ]]; then
  assert "upload preserves the unrelated_secret key" \
    $(jq -e '.unrelated_secret == "fake-decoy-do-not-use"' "$UPLOAD_CAPTURE" >/dev/null 2>&1 && echo 0 || echo 1)

  MISSING_KEYS=0
  for key in cloudflare_aop_ca_private_key_pem cloudflare_aop_ca_private_key_passphrase \
    cloudflare_aop_ca_certificate_pem \
    cloudflare_aop_production_certificate_pem cloudflare_aop_production_private_key_pem \
    cloudflare_aop_staging_certificate_pem cloudflare_aop_staging_private_key_pem; do
    jq -e --arg k "$key" '(.[$k] | type == "string") and (.[$k] | length > 0)' \
      "$UPLOAD_CAPTURE" >/dev/null 2>&1 || MISSING_KEYS=$((MISSING_KEYS + 1))
  done
  assert "all seven mTLS keys survive the merge ($MISSING_KEYS missing)" \
    $([[ "$MISSING_KEYS" -eq 0 ]] && echo 0 || echo 1)

  assert "CA key/cert/passphrase are untouched" \
    $(jq -e --slurpfile before "$ROTATION_FIXTURE" '
        .cloudflare_aop_ca_private_key_pem == $before[0].cloudflare_aop_ca_private_key_pem
        and .cloudflare_aop_ca_certificate_pem == $before[0].cloudflare_aop_ca_certificate_pem
        and .cloudflare_aop_ca_private_key_passphrase == $before[0].cloudflare_aop_ca_private_key_passphrase
      ' "$UPLOAD_CAPTURE" >/dev/null 2>&1 && echo 0 || echo 1)

  assert "the healthy staging leaf is byte-identical" \
    $(jq -e --slurpfile before "$ROTATION_FIXTURE" '
        .cloudflare_aop_staging_certificate_pem == $before[0].cloudflare_aop_staging_certificate_pem
        and .cloudflare_aop_staging_private_key_pem == $before[0].cloudflare_aop_staging_private_key_pem
      ' "$UPLOAD_CAPTURE" >/dev/null 2>&1 && echo 0 || echo 1)

  assert "the expiring production leaf was replaced" \
    $(jq -e --slurpfile before "$ROTATION_FIXTURE" '
        .cloudflare_aop_production_certificate_pem != $before[0].cloudflare_aop_production_certificate_pem
        and .cloudflare_aop_production_private_key_pem != $before[0].cloudflare_aop_production_private_key_pem
      ' "$UPLOAD_CAPTURE" >/dev/null 2>&1 && echo 0 || echo 1)

  NEW_LEAF_DIR="$WORK_DIR/new-production"
  mkdir -p "$NEW_LEAF_DIR"
  jq -r '.cloudflare_aop_production_certificate_pem' "$UPLOAD_CAPTURE" > "$NEW_LEAF_DIR/cert.crt"
  jq -r '.cloudflare_aop_ca_certificate_pem' "$UPLOAD_CAPTURE" > "$NEW_LEAF_DIR/rootca.crt"

  assert "the new leaf verifies against the fixture CA" \
    $(openssl verify -CAfile "$NEW_LEAF_DIR/rootca.crt" "$NEW_LEAF_DIR/cert.crt" >/dev/null 2>&1 && echo 0 || echo 1)
  assert "the new leaf is usable as a TLS client certificate" \
    $(openssl x509 -purpose -noout -in "$NEW_LEAF_DIR/cert.crt" 2>/dev/null | grep -q 'SSL client : Yes' && echo 0 || echo 1)
  assert "the new leaf carries clientAuth EKU" \
    $(openssl x509 -noout -text -in "$NEW_LEAF_DIR/cert.crt" 2>/dev/null | grep -q 'TLS Web Client Authentication' && echo 0 || echo 1)
  assert "the new leaf is RSA-4096" \
    $(openssl x509 -noout -text -in "$NEW_LEAF_DIR/cert.crt" 2>/dev/null | grep -q 'Public-Key: (4096 bit)' && echo 0 || echo 1)
  assert "the new leaf CN is the configured common name" \
    $(openssl x509 -noout -subject -in "$NEW_LEAF_DIR/cert.crt" 2>/dev/null | grep -q 'CN *= *example.com' && echo 0 || echo 1)
  assert "the new leaf is valid for about 730 days" \
    $(openssl x509 -checkend $((729 * 86400)) -noout -in "$NEW_LEAF_DIR/cert.crt" >/dev/null 2>&1 \
      && ! openssl x509 -checkend $((731 * 86400)) -noout -in "$NEW_LEAF_DIR/cert.crt" >/dev/null 2>&1 \
      && echo 0 || echo 1)
fi

assert "the vault document reached aws only as a file:// reference" \
  $(grep -q "secret-string file://" "$AWS_ARGS_LOG" && echo 0 || echo 1)
assert "no PEM material appears in the aws arguments" \
  $(grep -q "BEGIN " "$AWS_ARGS_LOG" && echo 1 || echo 0)
assert "terraform ran init, plan and apply" \
  $([[ "$(grep -c -E '^-chdir=\S+ (init|plan|apply)' "$TERRAFORM_ARGS_LOG")" -eq 3 ]] && echo 0 || echo 1)
assert "CI=1 selects the -backend-config=profile= init override" \
  $(grep -q -- "-backend-config=profile=" "$TERRAFORM_ARGS_LOG" && echo 0 || echo 1)
assert "every terraform invocation targeted the configured root only" \
  $([[ "$(grep -c -- "-chdir=$FAKE_TERRAFORM_ROOT " "$TERRAFORM_ARGS_LOG")" -eq "$(wc -l < "$TERRAFORM_ARGS_LOG" | tr -d ' ')" ]] && echo 0 || echo 1)
assert "the rendered tfvars file is cleaned up" \
  $([[ ! -f "$FAKE_TERRAFORM_ROOT/aop.auto.tfvars.json" ]] && echo 0 || echo 1)
assert "no saved plan file is left behind" \
  $([[ ! -f "$FAKE_TERRAFORM_ROOT/rotation.tfplan" ]] && echo 0 || echo 1)
assert "rotation run leaves no temp directory behind" \
  $([[ -z "$(ls -A "$SCRIPT_TMPDIR")" ]] && echo 0 || echo 1)
assert "rotation run never prints PEM material" \
  $(grep -q "BEGIN " "$WORK_DIR/rotation-stdout.log" "$WORK_DIR/rotation-stderr.log" && echo 1 || echo 0)
assert "rotation run never prints the CA passphrase" \
  $(grep -q "$CA_PASSPHRASE" "$WORK_DIR/rotation-stdout.log" "$WORK_DIR/rotation-stderr.log" && echo 1 || echo 0)

# ---------------------------------------------------------------------------
# Case 8: healthy leaves still converge the edge
#
# A previous run may have written the vault and then failed its apply; the
# next run sees fresh leaves, so convergence must not be skipped or the old
# certificate would stay on the edge while every run reports success.
# ---------------------------------------------------------------------------
echo "-- case 8: no rotation due, edge still converged"
NOOP_FIXTURE="$(build_fixture noop 3650 700 700)"
: > "$AWS_ARGS_LOG"
: > "$TERRAFORM_ARGS_LOG"
rm -f "$UPLOAD_CAPTURE"
export MTLS_TEST_VAULT_SOURCE="$NOOP_FIXTURE"

set +e
TMPDIR="$SCRIPT_TMPDIR" PATH="$SUCCESS_SHIM_DIR:$PATH" \
  MTLS_TERRAFORM_ROOT="$FAKE_TERRAFORM_ROOT" \
  bash "$SCRIPT_UNDER_TEST" \
  >"$WORK_DIR/noop-stdout.log" 2>"$WORK_DIR/noop-stderr.log"
NOOP_EXIT=$?
set -e

assert "no-op run exits 0" $([[ "$NOOP_EXIT" -eq 0 ]] && echo 0 || echo 1)
assert "no-op run reports rotation-not-required" \
  $(grep -qx "rotation-not-required" "$WORK_DIR/noop-stdout.log" && echo 0 || echo 1)
assert "no-op run still converges the edge" \
  $(grep -qx "edge-converged" "$WORK_DIR/noop-stdout.log" && echo 0 || echo 1)
assert "no-op run runs terraform init, plan and apply" \
  $([[ "$(grep -c -E '^-chdir=\S+ (init|plan|apply)' "$TERRAFORM_ARGS_LOG")" -eq 3 ]] && echo 0 || echo 1)
assert "no CI means no -backend-config override" \
  $(grep -q -- "-backend-config=profile=" "$TERRAFORM_ARGS_LOG" && echo 1 || echo 0)
assert "no-op run writes no new secret version" \
  $(grep -q "put-secret-value" "$AWS_ARGS_LOG" && echo 1 || echo 0)
assert "no-op run issues no certificate" $([[ ! -f "$UPLOAD_CAPTURE" ]] && echo 0 || echo 1)
assert "no-op run cleans up the rendered tfvars" \
  $([[ ! -f "$FAKE_TERRAFORM_ROOT/aop.auto.tfvars.json" ]] && echo 0 || echo 1)

# ---------------------------------------------------------------------------
# Case 9: script hygiene
# ---------------------------------------------------------------------------
echo "-- case 9: script hygiene"
assert "script is executable" $([[ -x "$SCRIPT_UNDER_TEST" ]] && echo 0 || echo 1)
assert "script mode is 755 (got $(file_mode "$SCRIPT_UNDER_TEST" 2>/dev/null || echo none))" \
  $([[ "$(file_mode "$SCRIPT_UNDER_TEST" 2>/dev/null || echo none)" == "755" ]] && echo 0 || echo 1)
assert "script never enables xtrace" \
  $(grep -qE '^[[:space:]]*set[[:space:]]+-[a-z]*x' "$SCRIPT_UNDER_TEST" && echo 1 || echo 0)
assert "script sets umask 077" \
  $(grep -qE '^umask 077' "$SCRIPT_UNDER_TEST" && echo 0 || echo 1)
assert "the passphrase is dropped from the environment before aws/terraform" \
  $(grep -qE '^unset MTLS_CA_PASSPHRASE$' "$SCRIPT_UNDER_TEST" && echo 0 || echo 1)
CHDIR_TARGETS="$(grep -oE -- '-chdir="[^"]+"' "$SCRIPT_UNDER_TEST" | sort -u | tr '\n' ' ')"
assert "every terraform -chdir points at the configured root (got: $CHDIR_TARGETS)" \
  $([[ "$CHDIR_TARGETS" == '-chdir="$TERRAFORM_ROOT" ' ]] && echo 0 || echo 1)

echo ""
if [[ "$FAILURES" -eq 0 ]]; then
  echo "All checks passed."
  exit 0
else
  echo "$FAILURES check(s) failed."
  exit 1
fi
