# This template renders a complete 'machineConfiguration' for a single node
# using data sourced from the 'nodes' data source.

machine:
  hostname: ${node.hostname}
  ipAddress: ${node.ipAddress}
  # Core Machine Definition
  machineSpec:
    secureboot: ${node.machineSpec.secureboot}

  # Disk provisioning details
  installDiskSelector:
    serial: "${node.installDiskSelector.serial}"
  userVolumes:
    ${#node.userVolumes.length}
    {{- range $volume := node.userVolumes}}
    - name: {{.name}}
      provisioning:
        diskSelector:
          match: "{{.provisioning.diskSelector.match}}"
        minSize: {{.provisioning.minSize}}
        maxSize: {{.provisioning.maxSize}}
    {{- end}}

  # Network configuration (The most complex section, replicated from the source data)
  networkInterfaces:
    {{- range $net := node.networkInterfaces}}
    {{- if eq $net.deviceSelector.hardwareAddr "N/A" }}
      - interface: {{.interface}}
        bond: {{.bond}}
        dhcp: {{.dhcp}}
        addresses: {{.addresses}}
        mtu: {{.mtu}}
        vip: {{.vip}}
        vlans:
          {{- range $vlan := .vlans}}
          - {vlanId: $vlan.vlanId, dhcp: false, mtu: $vlan.mtu}
          {{- end}}
    {{- else if .deviceSelector }}
      - deviceSelector:
          hardwareAddr: "{{.deviceSelector.hardwareAddr}}"
        ignore: true
    {{- else}}
      - interface: {{.interface}}
        bond: {{.bond}}
        dhcp: {{.dhcp}}
        addresses: {{.addresses}}
        mtu: {{.mtu}}
        vip: {{.vip}}
        vlans:
          {{- range $vlan := .vlans}}
          - {vlanId: $vlan.vlanId, dhcp: false, mtu: $vlan.mtu}
          {{- end}}
    {{- end}}

  # System Overrides and Services
  extensionServices:
    {{- range $ext := node.extensionServices}}
    - name: {{.name}}
      configFiles:
        - mountPath: {{.mountPath}}
          content: |
            {{.content}}
    {{- end}}

  # Patches are handled via specific patches/ directories in the final manifest,
  # but we include the placeholder reference here for completeness.
  patches:
    {{- range $patch := node.patches}}
    - "{{.}}"
    {{- end}}
