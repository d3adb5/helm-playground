{{- define "bluegreen.stable" -}}
  {{- $stableService := printf "%s-stable" .Release.Name | lookup "v1" "Service" .Release.Namespace -}}
  {{- $stableVersion := "blue" -}}

  {{- if $stableService -}}
    {{- $stableVersion = $stableService.spec.selector.bluegreen -}}
  {{- end -}}

  {{- $stableVersion -}}
{{- end -}}

{{- define "bluegreen.preview" -}}
  {{- include "bluegreen.stable" . | include "_bluegreen.flip" -}}
{{- end -}}

{{- define "_bluegreen.flip" -}}
  {{- if eq . "blue" -}} green
  {{- else -}} blue
  {{- end -}}
{{- end -}}
