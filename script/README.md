# Scripts

Helper scripts shared between projects. Everything here is parametrized —
nothing is specific to a single consumer.

## mTLS / Cloudflare Authenticated Origin Pulls (AOP)

Four scripts cover the lifecycle of the client certificates Cloudflare
presents to an ALB that requires mTLS:

| Script | Purpose |
| --- | --- |
| `generate-mtls-certs.sh` | One-off bootstrap: mint a root CA plus a first leaf. |
| `rotate-mtls-certificates.sh` | Issue a single replacement leaf from an existing CA. |
| `mtls-rotate-leaves.sh` | Unattended, per-zone rotation: decide, issue, store, converge. |
| `mtls-render-terraform-vars.sh` | Project a secrets vault document to a tfvars file. |

`mtls-rotate-leaves.sh` calls the other two: `rotate-mtls-certificates.sh`
does the openssl work for one leaf, `mtls-render-terraform-vars.sh` renders
the tfvars file Terraform consumes. All three must stay siblings in the same
directory.

### Vault layout

The rotation script expects a single AWS Secrets Manager secret whose value is
a flat JSON object. Only the prefixed keys below are read or written; every
other key in the document (database passwords, API tokens, ...) is preserved
untouched on write and never rendered to disk.

With `MTLS_VAULT_KEY_PREFIX="cloudflare_aop_"` (the default) and
`MTLS_ZONES="production=example.com"`:

```json
{
  "cloudflare_aop_ca_private_key_pem": "-----BEGIN ENCRYPTED PRIVATE KEY----- ...",
  "cloudflare_aop_ca_private_key_passphrase": "...",
  "cloudflare_aop_ca_certificate_pem": "-----BEGIN CERTIFICATE----- ...",
  "cloudflare_aop_production_certificate_pem": "-----BEGIN CERTIFICATE----- ...",
  "cloudflare_aop_production_private_key_pem": "-----BEGIN PRIVATE KEY----- ..."
}
```

### `mtls-render-terraform-vars.sh`

```sh
MTLS_ZONES="production" \
  script/mtls-render-terraform-vars.sh vault.json terraform/cloudflare/aop.auto.tfvars.json
```

Writes an allowlist projection (mode `0600`) and drops everything else:

- `<prefix>ca_certificate_pem` → `aop_ca_certificate_pem`
- `<prefix><slug>_certificate_pem` → `aop_<slug>_certificate_pem`
- `<prefix><slug>_private_key_pem` → `aop_<slug>_private_key_pem`

| Variable | Default | Meaning |
| --- | --- | --- |
| `MTLS_ZONES` | *required* | Comma-separated zone slugs, e.g. `production` or `production,staging`. A `=<common-name>` suffix is accepted and ignored, so one value can be shared with `mtls-rotate-leaves.sh`. |
| `MTLS_VAULT_KEY_PREFIX` | `cloudflare_aop_` | Prefix of the vault keys to read. |

A missing or empty required key is a hard error. Secret values are never
printed, not even in error paths.

### `mtls-rotate-leaves.sh`

```sh
# report only — no AWS, Terraform or network calls at all
MTLS_ZONES="production=example.com" \
  MTLS_SECRET_ID="my-project/terraform/production" \
  script/mtls-rotate-leaves.sh --check-only

# rotate what is due, then always converge the edge
MTLS_ZONES="production=example.com,staging=staging.example.com" \
  MTLS_SECRET_ID="my-project/terraform/production" \
  MTLS_TERRAFORM_ROOT="terraform/cloudflare" \
  script/mtls-rotate-leaves.sh
```

| Variable | Default | Meaning |
| --- | --- | --- |
| `MTLS_ZONES` | *required* | Comma-separated `slug=common-name` pairs. The slug names the vault keys and the Terraform variables; the common name goes into the certificate subject. |
| `MTLS_SECRET_ID` | *required* (unless `--vault-file`) | Secrets Manager secret holding the vault document. |
| `MTLS_TERRAFORM_ROOT` | *required in rotate mode* | The only Terraform root the script may `init`/`plan`/`apply`. |
| `MTLS_VAULT_KEY_PREFIX` | `cloudflare_aop_` | Prefix of the vault keys. |
| `MTLS_ROTATION_THRESHOLD_DAYS` | `60` | Rotate a leaf with less than this remaining. |
| `MTLS_LEAF_VALIDITY_DAYS` | `730` | Validity of a freshly issued leaf. |
| `MTLS_CA_MIN_REMAINING_YEARS` | `2` | Fail the run once the CA has less than this remaining. |
| `MTLS_TFVARS_PATH` | `$MTLS_TERRAFORM_ROOT/aop.auto.tfvars.json` | Rendered tfvars file; removed by the exit trap. |
| `MTLS_AWS_PROFILE` | *(unset)* | Local AWS profile. Unset means ambient credentials. Ignored when `CI` is set. |
| `MTLS_CERT_SUBJECT_BASE` | `/C=US/ST=State/L=City/O=Company` | Certificate subject minus the common name. |

Flags: `--check-only` reports the decision and exits; `--vault-file PATH`
reads a fixture document instead of Secrets Manager and is only accepted
together with `--check-only`.

Behaviour worth knowing before wiring this up:

- **Per-zone decisions.** Only zones whose leaf is inside the threshold are
  reissued. Healthy zones keep their existing certificate byte-for-byte.
- **Convergence is unconditional.** Even when nothing is due, the script
  renders the tfvars and runs `init`/`plan`/`apply`. A previous run that wrote
  the vault and then failed its apply would otherwise see a fresh leaf,
  report `rotation-not-required` forever and leave the old certificate on the
  edge. With healthy leaves this is a zero-diff no-op.
- **Stdout is the contract.** One of `rotation-required` /
  `rotation-not-required` in check-only mode; `rotation-complete` or
  `edge-converged` in rotate mode. On success after apply, `converged=true`
  is appended to `$GITHUB_OUTPUT` when that variable is set, so a workflow can
  gate its verification step.
- **The CA is never rotated here.** Root rotation is manual and overlapping.
  Instead the run emits `::error::mTLS root CA expires within N days` and
  exits non-zero once the CA crosses 90, 180, 365 or
  `MTLS_CA_MIN_REMAINING_YEARS × 365` days remaining — the leaf decision is
  still reported first. Note that a leaf may not outlive its issuer, so
  issuance itself is refused once the CA has less time left than
  `MTLS_LEAF_VALIDITY_DAYS`; with the defaults that is the same moment the
  two-year alarm starts firing. Treat that alarm as the deadline it is.
- **Secret hygiene.** Every value lives in a `0700` mktemp directory removed
  by a trap on any exit, reaches openssl through files or `-passin env:`, and
  is never echoed. The vault document is uploaded via
  `--secret-string file://`, so it never appears in process arguments. Do not
  add `set -x` to these scripts.
- **CI credentials.** When `CI` is set, `terraform init` is given
  `-backend-config=profile=` so a backend that pins a local profile falls back
  to the workflow's ambient credentials.

### Calling it from a consumer's workflow

The scripts ship with the module, so a consumer that already uses a module
from this repo can run them straight out of the module cache:

```yaml
- uses: hashicorp/setup-terraform@v3

- name: init (populates .terraform/modules)
  run: terraform -chdir=terraform/cloudflare init -input=false

- name: rotate mTLS leaves
  id: rotate
  env:
    MTLS_ZONES: production=example.com
    MTLS_SECRET_ID: my-project/terraform/production
    MTLS_TERRAFORM_ROOT: terraform/cloudflare
  run: .terraform/modules/cloudflare/script/mtls-rotate-leaves.sh

- name: verify the edge
  if: steps.rotate.outputs.converged == 'true'
  run: ./script/verify-edge.sh
```

Replace `cloudflare` in the cache path with the module key the consumer used
in its `module "..." {}` block. Pin the module `ref` so the script cannot
change under a scheduled run.

## Tests

`script/tests/*.sh` are self-contained behaviour tests. They mint throwaway
certificates locally and shadow `aws`, `terraform` and `curl` with PATH shims,
so they make no external calls and need no credentials:

```sh
bash script/tests/mtls-render-terraform-vars-test.sh
bash script/tests/mtls-rotate-leaves-test.sh
```

They require `bash`, `jq` and `openssl` and pass on both macOS and Linux.
