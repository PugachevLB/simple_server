{{/*
Expand the name of the chart.
*/}}
{{- define "typicalapp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "typicalapp.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "typicalapp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "typicalapp.labels" -}}
helm.sh/chart: {{ include "typicalapp.chart" . }}
{{ include "typicalapp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Return common labels as dict
*/}}
{{- define "typicalapp.labelsAsDict" -}}
{{- $vals := default dict .values -}}
{{- $root := .root -}}
  {{- $result := dict
    "helm.sh/chart" ( include "typicalapp.chart" $root )
    "app.kubernetes.io/managed-by" $root.Release.Service
  -}}
  {{- if $root.Chart.AppVersion }}
    {{- $_ := set $result "app.kubernetes.io/version" ($root.Chart.AppVersion | quote) -}}
  {{- end }}
  {{- $result | toYaml -}}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "typicalapp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "typicalapp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "typicalapp.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "typicalapp.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "typicalapp.componentEnabled" -}}
{{- $vals := .values -}}
{{- if not $vals -}}
false
{{- else -}}
  {{- /* default treats false as empty, so avoid it here */ -}}
  {{- $enabled := true -}}
  {{- if hasKey $vals "enabled" -}}
    {{- $enabled = $vals.enabled -}}
  {{- end -}}
  {{- $s := lower (trim (toString $enabled)) -}}
  {{- if or (eq $s "false") (eq $s "0") (eq $s "no") (eq $s "off") -}}
false
  {{- else -}}
true
  {{- end -}}
{{- end }}
{{- end }}

{{- define "typicalapp.componentChecksum" -}}
{{- $resource := default "configmap" .resource -}}
{{- $templates := dict
    "configmap" "typicalapp.configmap"
    "secret" "typicalapp.secret"
-}}
{{- $template := get $templates $resource -}}
{{- if not $template }}
  {{- fail (printf "unsupported resource '%s' for checksum" $resource) -}}
{{- end }}
{{- $render := include $template (dict
      "root" .root
      "name" .name
      "values" .values
  ) -}}
{{- if $render }}
{{- trimSuffix "\n" (sha256sum $render) -}}
{{- end }}
{{- end }}
