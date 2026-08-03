---
description: Intel NUC configuration on Talos Linux — driver selection and network interfaces
---

# NUCx

The talos-homelab site runs 2x Intel NUC nodes (nuc1 through nuc2)
as GPU worker nodes in the talos-homelab Kubernetes cluster, providing inference
and model loading capabilities.

## Hardware

- **CPU**: Intel® Core™ i9-13900H
- **GPU**: Intel® Iris® Xe Graphics
- **Memory**: 64GB
- **Storage**: 500GB NVMe (Talos Boot)
- **NICs**: 1x 1G copper

#### Talos Extensions

| Extension | Purpose |
|-----------|---------|
| `siderolabs/i915` | Intel Arc iGPU support (media transcoding) |
| `siderolabs/intel-ucode` | CPU microcode updates |
| `siderolabs/lldpd` | LLDP discovery |
| `siderolabs/mei` | Management Engine Interface |

## Intel GPU Resource Driver

Intel GPU Resource Driver is used to load the intel drivers.
drm-exporter is used to export GPU and power usage stats of the MS-01 nodes.

## Network Interfaces

Each NUC has 1 1G Copper link to the core switch
