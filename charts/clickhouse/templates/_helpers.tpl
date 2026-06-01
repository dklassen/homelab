{{- define "clickhouse.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "clickhouse.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "clickhouse.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "clickhouse.labels" -}}
helm.sh/chart: {{ include "clickhouse.chart" . }}
{{ include "clickhouse.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "clickhouse.selectorLabels" -}}
app.kubernetes.io/name: {{ include "clickhouse.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "clickhouse.shardSelectorLabels" -}}
{{ include "clickhouse.selectorLabels" .ctx }}
clickhouse/shard: {{ .shard.name }}
{{- end }}

{{/*
  clickhouse.dnsName
  Stable DNS prefix for pod FQDNs and service names — completely independent
  of Helm release name and chart name. Set via .Values.dnsName.
  Fails loudly at render time if not set.
  Usage: {{ include "clickhouse.dnsName" . }}
*/}}
{{- define "clickhouse.dnsName" -}}
{{- required ".Values.dnsName must be set" .Values.dnsName }}
{{- end }}

{{/*
  clickhouse.shardDnsName
  Stable DNS prefix for a specific shard: "<dnsName>-<shard.name>".
  Used for StatefulSet names, headless service names, and FQDN construction.
  Usage: {{ include "clickhouse.shardDnsName" (dict "ctx" $ "shard" $shard) }}
  FQDN pattern: <shardDnsName>-<ordinal>.<shardDnsName>-headless.<namespace>.svc.cluster.local
*/}}
{{- define "clickhouse.shardDnsName" -}}
{{- printf "%s-%s" (include "clickhouse.dnsName" .ctx) .shard.name }}
{{- end }}
