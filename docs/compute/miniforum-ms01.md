---
description: Minisforum MiniWorkStation MS-01 configuration on Talos Linux — driver selection, GPU operator, and network interfaces
---

# MS01

The talos-homelab site runs three Minisforum MS-01 nodes (ms01 through ms03)
as GPU controller nodes in the talos-homelab Kubernetes cluster, providing inference
and model loading capabilities.

## Hardware

- **CPU**: Intel® Core™ i9-13900H
- **GPU**: Intel® Iris® Xe Graphics
- **Memory**: 96GB
- **Storage**: 500GB NVMe (Talos Boot), WD_BLACK SN770 2TB (Openebs-local), SAMSUNG U.2 1.9TB (Ceph)
- **NICs**: 2x Intel X710 (bonded as bond0) SFP+ DAC cables, 2x Intel 1G copper (only 1 supports vPro)

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

Each MS-01 has 2 physical Intel X710 controller and 2.5Gbps RJ45 Ethernet ports.
The X710 ports have been bonded.
One of the 2.5Gbps ports is enabled for Intel vPro with the other being unused.
The vPro ports are disabled by the switch at 192.168.10.3 and can be enabled for emergency vPro access.

### Physical Port 0 — Bond0 via S3400-48T6SP
### Physical Port 1 — Bond0 via S3400-48T6SP

Connected via a 10G to 10G DAC cable to the main 48 port switch
(S3400-48T6SP, home-r01-msw01) for bonded cilium and Talos access

| Interface | Speed | MTU | Status |
|-----------|-------|-----|--------|
| enp2s0f0np0 | 10G | 1500 | connected |
| enp2s0f1np1 | 10G | 1500 | disconnected |

### Physical Port 3 — vPro

vPro interfaces are ignored in talos config using the mac of the interface
Enabling the interface can interfere with the routing table so I've always enabled the switch port when needed.

| Interface | Speed | MTU | Status |
|-----------|-------|-----|--------|
| enp87s0 | 1G | 1500 | disabled |


### Physical Port 4 — not connected

| Interface | Speed | MTU | Status|
|-----------|-------|-----|-------|
| enp90s0 | 2.5G | 1500 | not used |
