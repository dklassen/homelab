{{- define "clickhouse-keeper.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "clickhouse-keeper.fullname" -}}
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

{{- define "clickhouse-keeper.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "clickhouse-keeper.labels" -}}
helm.sh/chart: {{ include "clickhouse-keeper.chart" . }}
{{ include "clickhouse-keeper.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "clickhouse-keeper.selectorLabels" -}}
app.kubernetes.io/name: {{ include "clickhouse-keeper.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
  clickhouse-keeper.dnsName
  Stable DNS prefix for pod FQDNs and headless service name — completely independent
  of Helm release name and chart name. Set via .Values.dnsName.
  Fails loudly at render time if not set.
  Usage: {{ include "clickhouse-keeper.dnsName" . }}
  FQDN pattern: <dnsName>-<ordinal>.<dnsName>-headless.<namespace>.svc.cluster.local
*/}}
{{- define "clickhouse-keeper.dnsName" -}}
{{- required ".Values.dnsName must be set" .Values.dnsName }}
{{- end }}
