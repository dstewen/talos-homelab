---
description: Compute Blade (https://computeblade.com/) configuration on Talos Linux — driver selection and  network interfaces
---

# MS01

The talos-homelab site runs three Minisforum MS-01 nodes (ms01 through ms03)
as GPU controller nodes in the talos-homelab Kubernetes cluster, providing inference
and model loading capabilities.

## Hardware

- **SoM**: Raspberry Pi Compute Module 4
- **Memory**: 8GB
- **Storage**: 500GB NVMe WD_BLUE (Talos Boot)
- **NIC**: 1x Broadcom 1G copper

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

### Physical Port 0 — Bond0 via fairy-r02-fsw01
### Physical Port 1 — Bond0 via fairy-r02-fsw01

Connected via a 400G to 2x200G DAC breakout cable to the GPU fabric switch
(MikroTik CRS804-4DDQ, fairy-r02-fsw01) for inter-node GPU communication
(GPUDirect RDMA, tensor/pipeline parallelism).

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
