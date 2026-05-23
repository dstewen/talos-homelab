# Home Operations - AI Assistant Guide

This is a **Home Kubernetes cluster monorepo** managed with GitOps (Flux, Renovate, GitHub Actions).

## CRITICAL: Treat This Repo As Public

Assume this repository is publicly accessible. Do not commit or propose changes that introduce personally identifiable information or sensitive infrastructure details.

### PII Protection Rules

Never commit any of the following:

| Prohibited | Use Instead | Example |
| --- | --- | --- |
| Real names | Pseudonyms or variables | `${USERNAME}` |
| Email addresses | Secret variables | `${SECRET_CLUSTER_DOMAIN_EMAIL}` |
| Public hostnames/domains | Secret variables | `app.${SECRET_DOMAIN}` |
| Public IP addresses | SOPS secret variables (add a `SECRET_*` entry) | `${SECRET_PUBLIC_IP}` |

Allowed in this repository:
- RFC1918 IP addresses (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)
- Hostnames used only inside the cluster (e.g. `svc.cluster.local`)
- Hardware model names and non-sensitive vendor references

### Secret and Variable Reference

All sensitive values are stored in SOPS-encrypted secrets and injected via Flux or External Secrets. Prefer these variables instead of hardcoding:

| Variable | Purpose | Location |
| --- | --- | --- |
| `${SECRET_DOMAIN}` | Base domain for email or app config | `kubernetes/components/common/vars/cluster-secrets.sops.yaml` |
| `${SECRET_EXTERNAL_DOMAIN}` | Public ingress domain | `kubernetes/components/common/vars/cluster-secrets.sops.yaml` |
| `${SECRET_INTERNAL_DOMAIN}` | Internal DNS domain | `kubernetes/components/common/vars/cluster-secrets.sops.yaml` |
| `${SECRET_CLUSTER_DOMAIN_EMAIL}` | ACME/cluster email | `kubernetes/components/common/vars/cluster-secrets.sops.yaml` |
| `${SECRET_CLOUDFLARE_TUNNEL_ID}` | Cloudflare Tunnel ID | `kubernetes/components/common/vars/cluster-secrets.sops.yaml` |

Non-secret cluster values (e.g. load balancer IPs, time zone, CIDRs) live in `kubernetes/components/common/vars/cluster-settings.yaml`.

### Secret Handling Rules

- Encrypt all secrets with SOPS following `.sops.yaml` rules.
- Use `*.sops.yaml` (or other `*.sops.*`) for Kubernetes secrets.
- Do not commit plaintext secrets or credentials anywhere.
- App secrets should use External Secrets with `ClusterSecretStore` named `onepassword-connect`.

## CRITICAL CONTEXT

This repository manages home infrastructure as code.

- Kubernetes GitOps is managed by Flux.
- Cluster OS and provisioning are managed by Talos Linux.
- Renovate automates dependency updates.

## BEHAVIORAL GUIDELINES

1. Research existing patterns before proposing changes.
2. Preserve current functionality unless explicitly asked to remove it.
3. Keep GitOps as the source of truth. Avoid `kubectl apply` outside documented bootstrap flows.
4. Prefer existing patterns for HelmRelease, Kustomization, ExternalSecret, and Gateway API resources.
5. Keep security tight. Do not add `privileged`, `hostNetwork`, or `runAsUser: 0` without a clear need.
6. Validate changes locally when possible and call out any gaps.
7. Always ignore the `.archive/` folder when making or proposing changes.

## ANTI-PATTERNS

- Hardcoding domains, emails, API keys, or public IPs.
- Adding secrets to non-SOPS files.
- Introducing manual, out-of-band cluster changes.
- Diverging from existing namespace/app layouts without justification.

## SECURITY BASELINE

Use least privilege defaults when adding new workloads:

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 65534
  allowPrivilegeEscalation: false
  capabilities:
    drop: ["ALL"]
  readOnlyRootFilesystem: true
```
Add resource requests/limits unless there is a strong reason not to:

```yaml
resources:
  requests:
    cpu: "100m"
    memory: "256Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
```

## Repository Structure

```
talos-homelab/
├── kubernetes/           # Kubernetes configurations (Flux-managed)
│   ├── apps/            # Namespaced app deployments
│   ├── clusters/        # Flux cluster definitions
│   └── components/      # Reusable k8s components
├── talos/               # Talos Linux machine configs
├── bootstrap/           # Bootstrap templates (helmfile.d, templates)
├── docs/                # mdBook documentation
└── scripts/              # Talos helper scripts
```

## Key Technologies

| Category   | Tool                         | Purpose                           |
|------------|------------------------------|-----------------------------------|
| GitOps     | Flux                         | Deploys configs from Git to k8s   |
| CI         | Renovate + GitHub Actions    | Dependency updates, automation    |
| Networking | cilium (eBPF)                | CNI, BGP, service mesh            |
| Ingress    | Envoy Gateway                | L7 proxy, ingress controller      |
| DNS        | external-dns                 | Syncs ingress to Cloudflare/UniFi |
| Secrets    | external-secrets + 1Password | Secret management                 |
| Storage    | Rook/Ceph + volsync          | Distributed storage + backups     |
| Images     | spegel                       | Local OCI mirror                  |

## GitOps Flow

```
Git push → Flux source sync → Kustomization → HelmRelease → k8s resources
```

Flux recursively searches `kubernetes/${cluster}/apps/` for `kustomization.yaml` files. Each must define a namespace and Flux kustomization (`ks.yaml`).

## Conventions

- Component READMEs stay with components (e.g., `kubernetes/apps/base/cilium/README.md`)
- Secrets stored in 1Password, referenced via `external-secrets`
- SOPS used for encrypting sensitive values in Git
- Apps use `HelmRelease` via Flux, rarely raw manifests
- Clusters are mostly identical except for app selections and sizing

## Common Operations

- **Add app**: Create in `kubernetes/apps/${cluster}/` with kustomization + HelmRelease
- **Update app**: Merge renovate PR or manually edit and push
- **Troubleshoot**: Check `flux get all -n <namespace>`, `kubectl get events --sort-by=.lastTimestamp`
- **Scripts**: `hack/` contains operational scripts (cert-extract.sh, delete-stuck-ns.sh, etc.)
- **Validate locally**: Run `flux-local` before pushing GitOps changes:
  ```bash
  # Test both kustomizations and HelmReleases
  /Users/joryirving/.local/share/mise/installs/pipx-flux-local/8.1.0/bin/flux-local test --enable-helm --path ./kubernetes/clusters/main

  # Diff a specific HelmRelease or Kustomization
  /Users/joryirving/.local/share/mise/installs/pipx-flux-local/8.1.0/bin/flux-local diff helmrelease --path ./kubernetes/clusters/main --limit-bytes 10000
  ```
- **Gateway policy namespace rule**: `ClientTrafficPolicy` and `EnvoyPatchPolicy` that target a `Gateway` must live in the same namespace as that `Gateway`. For `envoy-internal`, put those resources in `kubernetes/apps/base/network/envoy-gateway/config/` with namespace `network`.

## Documentation

- Main docs: `/docs/src/` (mdBook)
- Component docs: README files co-located with components
- Personal notes: `/docs/src/notes/`

## Adding Documentation

When adding architecture or operational docs, consider:
1. Put user-facing docs in `/docs/src/`
2. Keep component-specific docs with the component
3. Personal notes go in `/docs/src/notes/`

## PR Review Standards

When reviewing Renovate PRs, enforce these criteria:

### HelmRelease Requirements
- All applications MUST use `HelmRelease` via Flux, not raw manifests
- Must include `spec.chart.spec.version` for pinned chart versions outside of `app-template`
- Must include `spec.interval` for reconciliation frequency
- Resource limits (CPU/memory) SHOULD be specified for production workloads, but this is not a hard requirement
- `valuesFrom` should reference ConfigMaps/Secrets, not inline values

### Secret Management Rules
- **NEVER** commit plain-text secrets or credentials in Git
- All secrets MUST use `external-secrets` with 1Password backend
- SOPS encryption required for any sensitive values in Git
- If a PR introduces a new secret, verify it's external-secrets backed

### Image & Digest Policy
- Prefer `@sha256:` digests over version tags for reproducibility
- For tag-only updates, verify OCI metadata (revision/source/created)
- If revision changes between digests, ensure it's intentional
- Reject updates from untrusted registries (must be allowlisted)
- Preferred registries: GHCR.io, registry.k8s.io, Docker Hub (fallback)
- Avoid Docker Hub for critical infrastructure components

### Cluster-Specific Policies
- **main cluster** (production): Strict validation - all standards must be met
- **utility cluster** (low-power services, production): Strict validation - all standards must be met
- **test cluster** (testing): Can accept bleeding-edge versions, still enforce secrets policy

### Breaking Change Detection
Always `request_changes` if:
- API version changes (e.g., `apiVersion: apps/v1beta1` → `apps/v1`)
- Deprecated field usage introduced
- Major version bumps without justification
- CRD changes or custom resource modifications
- Network policy or security context relaxations

### Required Evidence for Approval
Before approving, verify:
1. Release notes/changelog mention the upgrade
2. GitHub compare shows expected changes
3. Version aligns with what Renovate reported
4. No breaking changes identified in release notes
5. Security advisories don't apply to this version

_Flux automatically reconciles changes once the PR is merged._
