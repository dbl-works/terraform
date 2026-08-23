#!/usr/bin/env bash
#
# Behavior test for script/mtls-render-terraform-vars.sh
#
# Verifies the allowlist projection: exactly the configured mTLS fields are
# mapped to their Terraform variable names, any other vault key (e.g. a decoy
# `unrelated_secret`) is dropped, output file mode is 0600, and a missing or
# empty required key causes a non-zero exit without leaking values.
#
# Run with: bash script/tests/mtls-render-terraform-vars-test.sh

set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_UNDER_TEST="$TEST_DIR/../mtls-render-terraform-vars.sh"

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

export MTLS_ZONES="production,staging"

echo "== mtls-render-terraform-vars.sh behavior tests =="

# ---------------------------------------------------------------------------
# Case 1: full fixture with a decoy key -> exact allowlist projection
# ---------------------------------------------------------------------------
echo "-- case 1: complete two-zone fixture"
FIXTURE="$WORK_DIR/vault.json"
OUTPUT="$WORK_DIR/terraform.tfvars.json"

cat > "$FIXTURE" <<'JSON'
{
  "unrelated_secret": "fake-decoy-do-not-use",
  "cloudflare_aop_ca_certificate_pem": "FAKE-CA-CERT-VALUE",
  "cloudflare_aop_production_certificate_pem": "FAKE-PRODUCTION-CERT-VALUE",
  "cloudflare_aop_production_private_key_pem": "FAKE-PRODUCTION-KEY-VALUE",
  "cloudflare_aop_staging_certificate_pem": "FAKE-STAGING-CERT-VALUE",
  "cloudflare_aop_staging_private_key_pem": "FAKE-STAGING-KEY-VALUE"
}
JSON

if bash "$SCRIPT_UNDER_TEST" "$FIXTURE" "$OUTPUT" >"$WORK_DIR/stdout.log" 2>"$WORK_DIR/stderr.log"; then
  assert "script exits 0 on a complete fixture" 0
else
  assert "script exits 0 on a complete fixture" 1
fi

assert "output file was created" $([[ -f "$OUTPUT" ]] && echo 0 || echo 1)

if [[ -f "$OUTPUT" ]]; then
  MODE="$(file_mode "$OUTPUT")"
  assert "output file mode is 600 (got $MODE)" $([[ "$MODE" == "600" ]] && echo 0 || echo 1)

  assert "aop_ca_certificate_pem mapped correctly" \
    $(jq -e '.aop_ca_certificate_pem == "FAKE-CA-CERT-VALUE"' "$OUTPUT" >/dev/null 2>&1 && echo 0 || echo 1)
  assert "aop_production_certificate_pem mapped correctly" \
    $(jq -e '.aop_production_certificate_pem == "FAKE-PRODUCTION-CERT-VALUE"' "$OUTPUT" >/dev/null 2>&1 && echo 0 || echo 1)
  assert "aop_production_private_key_pem mapped correctly" \
    $(jq -e '.aop_production_private_key_pem == "FAKE-PRODUCTION-KEY-VALUE"' "$OUTPUT" >/dev/null 2>&1 && echo 0 || echo 1)
  assert "aop_staging_certificate_pem mapped correctly" \
    $(jq -e '.aop_staging_certificate_pem == "FAKE-STAGING-CERT-VALUE"' "$OUTPUT" >/dev/null 2>&1 && echo 0 || echo 1)
  assert "aop_staging_private_key_pem mapped correctly" \
    $(jq -e '.aop_staging_private_key_pem == "FAKE-STAGING-KEY-VALUE"' "$OUTPUT" >/dev/null 2>&1 && echo 0 || echo 1)

  assert "decoy key unrelated_secret is absent from output" \
    $(jq -e 'has("unrelated_secret") | not' "$OUTPUT" >/dev/null 2>&1 && echo 0 || echo 1)

  KEY_COUNT="$(jq 'keys | length' "$OUTPUT")"
  assert "output has exactly 5 keys (got $KEY_COUNT)" $([[ "$KEY_COUNT" -eq 5 ]] && echo 0 || echo 1)
fi

# ---------------------------------------------------------------------------
# Case 2: missing required key -> non-zero exit, no partial output leakage
# ---------------------------------------------------------------------------
echo "-- case 2: missing required key"
MISSING_FIXTURE="$WORK_DIR/vault-missing-staging-key.json"
MISSING_OUTPUT="$WORK_DIR/missing.tfvars.json"

jq 'del(.cloudflare_aop_staging_private_key_pem)' "$FIXTURE" > "$MISSING_FIXTURE"

set +e
bash "$SCRIPT_UNDER_TEST" "$MISSING_FIXTURE" "$MISSING_OUTPUT" >"$WORK_DIR/missing-stdout.log" 2>"$WORK_DIR/missing-stderr.log"
MISSING_EXIT=$?
set -e

assert "script rejects a fixture missing the staging private key" $([[ "$MISSING_EXIT" -ne 0 ]] && echo 0 || echo 1)
assert "no output file is left behind on rejection" $([[ ! -f "$MISSING_OUTPUT" ]] && echo 0 || echo 1)
assert "error output names the missing key" \
  $(grep -q "cloudflare_aop_staging_private_key_pem" "$WORK_DIR/missing-stderr.log" && echo 0 || echo 1)
assert "error output does not leak any fixture secret value" \
  $(grep -qE "FAKE-(CA|PRODUCTION|STAGING)-(CERT|KEY)-VALUE" "$WORK_DIR/missing-stderr.log" && echo 1 || echo 0)

# ---------------------------------------------------------------------------
# Case 3: empty-string required key -> non-zero exit
# ---------------------------------------------------------------------------
echo "-- case 3: empty required key"
EMPTY_FIXTURE="$WORK_DIR/vault-empty-staging-key.json"
EMPTY_OUTPUT="$WORK_DIR/empty.tfvars.json"

jq '.cloudflare_aop_staging_private_key_pem = ""' "$FIXTURE" > "$EMPTY_FIXTURE"

set +e
bash "$SCRIPT_UNDER_TEST" "$EMPTY_FIXTURE" "$EMPTY_OUTPUT" >"$WORK_DIR/empty-stdout.log" 2>"$WORK_DIR/empty-stderr.log"
EMPTY_EXIT=$?
set -e

assert "script rejects a fixture with an empty staging private key" $([[ "$EMPTY_EXIT" -ne 0 ]] && echo 0 || echo 1)
assert "no output file is left behind on empty-key rejection" $([[ ! -f "$EMPTY_OUTPUT" ]] && echo 0 || echo 1)

# ---------------------------------------------------------------------------
# Case 4: MTLS_ZONES drives the projection (single zone, custom prefix)
# ---------------------------------------------------------------------------
echo "-- case 4: single zone with a custom vault key prefix"
CUSTOM_FIXTURE="$WORK_DIR/custom-vault.json"
CUSTOM_OUTPUT="$WORK_DIR/custom.tfvars.json"

cat > "$CUSTOM_FIXTURE" <<'JSON'
{
  "unrelated_secret": "fake-decoy-do-not-use",
  "edge_mtls_ca_certificate_pem": "FAKE-CA-CERT-VALUE",
  "edge_mtls_production_certificate_pem": "FAKE-PRODUCTION-CERT-VALUE",
  "edge_mtls_production_private_key_pem": "FAKE-PRODUCTION-KEY-VALUE",
  "edge_mtls_staging_certificate_pem": "FAKE-STAGING-CERT-VALUE",
  "edge_mtls_staging_private_key_pem": "FAKE-STAGING-KEY-VALUE"
}
JSON

set +e
# The `slug=common-name` form is accepted so one MTLS_ZONES value can be
# shared with mtls-rotate-leaves.sh.
MTLS_VAULT_KEY_PREFIX="edge_mtls_" MTLS_ZONES="production=example.com" \
  bash "$SCRIPT_UNDER_TEST" "$CUSTOM_FIXTURE" "$CUSTOM_OUTPUT" \
  >"$WORK_DIR/custom-stdout.log" 2>"$WORK_DIR/custom-stderr.log"
CUSTOM_EXIT=$?
set -e

assert "custom prefix run exits 0" $([[ "$CUSTOM_EXIT" -eq 0 ]] && echo 0 || echo 1)
if [[ -f "$CUSTOM_OUTPUT" ]]; then
  CUSTOM_KEY_COUNT="$(jq 'keys | length' "$CUSTOM_OUTPUT")"
  assert "single-zone output has exactly 3 keys (got $CUSTOM_KEY_COUNT)" \
    $([[ "$CUSTOM_KEY_COUNT" -eq 3 ]] && echo 0 || echo 1)
  assert "custom prefix is stripped in the Terraform variable names" \
    $(jq -e '.aop_production_certificate_pem == "FAKE-PRODUCTION-CERT-VALUE"' "$CUSTOM_OUTPUT" >/dev/null 2>&1 && echo 0 || echo 1)
  assert "the unconfigured staging zone is not projected" \
    $(jq -e 'has("aop_staging_certificate_pem") | not' "$CUSTOM_OUTPUT" >/dev/null 2>&1 && echo 0 || echo 1)
else
  assert "single-zone output file was created" 1
fi

# ---------------------------------------------------------------------------
# Case 5: MTLS_ZONES is required
# ---------------------------------------------------------------------------
echo "-- case 5: MTLS_ZONES is required"
set +e
env -u MTLS_ZONES bash "$SCRIPT_UNDER_TEST" "$FIXTURE" "$WORK_DIR/no-zones.tfvars.json" \
  >"$WORK_DIR/no-zones-stdout.log" 2>"$WORK_DIR/no-zones-stderr.log"
NO_ZONES_EXIT=$?
set -e

assert "run without MTLS_ZONES is rejected" $([[ "$NO_ZONES_EXIT" -ne 0 ]] && echo 0 || echo 1)
assert "rejection names MTLS_ZONES" \
  $(grep -q "MTLS_ZONES" "$WORK_DIR/no-zones-stderr.log" && echo 0 || echo 1)
assert "no output file is left behind" $([[ ! -f "$WORK_DIR/no-zones.tfvars.json" ]] && echo 0 || echo 1)

# ---------------------------------------------------------------------------
# Case 6: a prefix carrying jq syntax must be rejected, not interpolated
#
# The projection filter is built by string interpolation, so a prefix such as
# `x"] | {injected:"yes"} | .["y` could rewrite the filter and write a file
# full of nulls while still exiting 0.
# ---------------------------------------------------------------------------
echo "-- case 6: invalid MTLS_VAULT_KEY_PREFIX"
INJECTION_OUTPUT="$WORK_DIR/injected.tfvars.json"
set +e
MTLS_VAULT_KEY_PREFIX='x"] | {injected: "yes"} | .["y' \
  bash "$SCRIPT_UNDER_TEST" "$FIXTURE" "$INJECTION_OUTPUT" \
  >"$WORK_DIR/injection-stdout.log" 2>"$WORK_DIR/injection-stderr.log"
INJECTION_EXIT=$?
set -e

assert "a prefix containing jq syntax is rejected" $([[ "$INJECTION_EXIT" -ne 0 ]] && echo 0 || echo 1)
assert "rejection names MTLS_VAULT_KEY_PREFIX" \
  $(grep -q "MTLS_VAULT_KEY_PREFIX" "$WORK_DIR/injection-stderr.log" && echo 0 || echo 1)
assert "no output file is written for an invalid prefix" \
  $([[ ! -f "$INJECTION_OUTPUT" ]] && echo 0 || echo 1)

# ---------------------------------------------------------------------------
# Case 7: multi-line MTLS_ZONES fails loudly instead of dropping zones
# ---------------------------------------------------------------------------
echo "-- case 7: whitespace in MTLS_ZONES"
MULTILINE_OUTPUT="$WORK_DIR/multiline.tfvars.json"
set +e
MTLS_ZONES="$(printf 'production\nstaging')" \
  bash "$SCRIPT_UNDER_TEST" "$FIXTURE" "$MULTILINE_OUTPUT" \
  >"$WORK_DIR/multiline-stdout.log" 2>"$WORK_DIR/multiline-stderr.log"
MULTILINE_EXIT=$?
set -e

assert "a multi-line MTLS_ZONES is rejected" $([[ "$MULTILINE_EXIT" -ne 0 ]] && echo 0 || echo 1)
assert "rejection mentions whitespace" \
  $(grep -qi "whitespace" "$WORK_DIR/multiline-stderr.log" && echo 0 || echo 1)
assert "no partial output is written for a multi-line MTLS_ZONES" \
  $([[ ! -f "$MULTILINE_OUTPUT" ]] && echo 0 || echo 1)

echo ""
if [[ "$FAILURES" -eq 0 ]]; then
  echo "All checks passed."
  exit 0
else
  echo "$FAILURES check(s) failed."
  exit 1
fi
