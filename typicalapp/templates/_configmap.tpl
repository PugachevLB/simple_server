{{/* ============================================================================
  include "typicalapp.configmap" (dict "root" . "name" "" "values" .Values)
*/}}
{{- define "typicalapp.configmap" -}}

{{- /* Component values scope. */ -}}
{{- $vals := default dict .values -}}

{{- /* ConfigMap-specific configuration block. */ -}}
{{- $configmaps := default dict $vals.configMaps -}}

{{- /* Root chart context (required for tpl and helpers). */ -}}
{{- $root := .root -}}

{{- $componentEnabled := eq
      (include "typicalapp.componentEnabled" (dict "values" $vals) | trim | lower)
      "true"
-}}

{{- range $index, $cfg := $configmaps }}

  {{- $render := and $componentEnabled (default false $cfg.enabled) -}}
  {{- if $render -}}
    {{/* dict (include "typicalapp.labels" $root) */}}
    {{- $labels := merge dict 
      (fromYaml (include "typicalapp.labelsAsDict" (dict "values" $vals "root" $root)))
      (default dict $vals.labels)
      (default dict $cfg.labels)
    -}}
    {{- $labels := include "typicalapp.labels" $root -}}
    {{- $fullnameOverride := coalesce $cfg.name $cfg.fullnameOverride $vals.fullnameOverride -}}

    {{- $data := default dict $cfg.data -}}
    {{- $binaryData := default dict $cfg.binaryData -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $fullnameOverride }}
  labels:
    {{- $labels | nindent 4 }}
data:
{{- if eq (len $data) 0 }}
  {}
{{- else if $cfg.tpl }}
  {{- $renderedData := dict }}
  {{- range $key, $value := $data }}
    {{- if kindIs "string" $value }}
      {{- $_ := set $renderedData $key (tpl $value $.root) }}
    {{- else }}
      {{- $_ := set $renderedData $key $value }}
    {{- end }}
  {{- end }}
{{ toYaml $renderedData | indent 2 }}
{{- else }}
{{ toYaml $data | indent 2 }}
{{- end }}

{{- if gt (len $binaryData) 0 }}
binaryData:
{{ toYaml $binaryData | indent 2 }}
{{- end }}

{{- end }}{{/* end if $render */}}
{{/*- printf "\n" -*/}}

{{- end }}{{/* end range $index, $cfg := $configmaps */}}

{{- end }}{{/* end define */}}
