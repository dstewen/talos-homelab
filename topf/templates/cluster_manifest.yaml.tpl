# topf Template: Cluster Manifest Root
# This template acts as the root entry point, consuming the cluster definition
# from data/cluster.yaml and iterating over all nodes listed in data/nodes.yaml
# to build the final, cohesive, and fully structured cluster manifest.

# 1. Load Core Cluster Data
{{- $clusterData := load "data/cluster.yaml" }}

# 2. The primary manifest structure is built here.
# This calls the node template for every node listed in the data source.
{{- range $node := (load "data/nodes.yaml").nodes }}
---
# Manifest generated for node: {{ $node.hostname }}
{{ template "node_machine" . }}
{{- end }}

# 3. Cluster-wide Overrides (Patches, Global Settings)
# Global patches that apply across ALL nodes or the cluster itself are defined here.
{{- range $patch := (load "data/cluster.yaml").globalPatches }}
---
# Global Patch: {{ $patch }}
{{/* This section will require specific rendering logic that abstracts the patch logic */}}
{{- end }}
