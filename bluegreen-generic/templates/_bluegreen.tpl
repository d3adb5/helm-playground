{{- define "bluegreen.stable" -}}
  {{- $stableService := lookup "v1" "Service" .Release.Namespace .Release.Name -}}
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


{{- /*
  Given the original scope and a list of rendered Ingress objects, create a
  stable and a preview version of each object.
*/ -}}


{{- define "bluegreen.ingresses" -}}
  {{- $scope     := index . 0 -}}
  {{- $ingresses := rest . -}}

  {{- range $ingresses }}
    {{- $ingressDict     := fromYaml . -}}
    {{- $previewOverride := include "bluegreen.ingress.override.preview" (list $scope $ingressDict) -}}
    {{- $previewIngress  := mergeOverwrite (deepCopy $ingressDict) (fromYaml $previewOverride) -}}

{{- toYaml $ingressDict }}
---
{{- toYaml $previewIngress }}
---
  {{- end }}
{{- end -}}

{{- define "bluegreen.ingress.override.preview" -}}
  {{- $scope    := index . 0 -}}
  {{- $ingress  := index . 1 -}}
metadata:
  name: {{ $ingress.metadata.name }}-preview
spec:
  rules:
    {{- range $ingress.spec.rules }}
    - host: preview.{{ .host }}
      http:
        paths:
          {{- range .http.paths }}
          - backend:
              service:
                name: {{ .backend.service.name }}-preview
                port: {{ toYaml .backend.service.port | nindent 18 }}
            {{- omit . "backend" | toYaml | nindent 12 }}
          {{- end }}
    {{- end }}
{{- end -}}


{{- /*
  Given the original scope and a list of rendered Service objects, create a
  stable and a preview version of each object.
*/ -}}


{{- define "bluegreen.services" -}}
  {{- $scope    := index . 0 -}}
  {{- $services := rest . -}}

  {{- range $services }}
    {{- $serviceDict     := fromYaml . -}}
    {{- $stableOverride  := include "bluegreen.service.override.stable"  $scope -}}
    {{- $previewOverride := include "bluegreen.service.override.preview" (list $scope $serviceDict) -}}

    {{- $stableService  := mergeOverwrite (deepCopy $serviceDict) (fromYaml $stableOverride) -}}
    {{- $previewService := mergeOverwrite (deepCopy $serviceDict) (fromYaml $previewOverride) -}}

{{- toYaml $stableService }}
---
{{- toYaml $previewService }}
---
  {{- end }}
{{- end -}}

{{- define "bluegreen.service.override.stable" -}}
spec:
  selector:
    {{- if .Values.promote }}
    bluegreen: {{ include "bluegreen.preview" . }}
    {{- else }}
    bluegreen: {{ include "bluegreen.stable" . }}
    {{- end }}
{{- end -}}

{{- define "bluegreen.service.override.preview" -}}
  {{- $scope   := index . 0 -}}
  {{- $service := index . 1 -}}
metadata:
  name: {{ $service.metadata.name }}-preview
spec:
  selector:
    bluegreen: {{ include "bluegreen.preview" $scope }}
{{- end -}}


{{- /*
  Given the original scope and the rendered Deployment object, attempt to
  preserve the stable Deployment is simply allow the current one to be created.
*/ -}}


{{- define "bluegreen.deployments" -}}
  {{- $scope      := index . 0 -}}
  {{- $deployment := index . 1 | fromYaml -}}
  {{- $overrides  := include "bluegreen.deployment.override.preview" $scope | fromYaml -}}

  {{- $stableName   := printf "%s-%s" $deployment.metadata.name (include "bluegreen.stable" $scope) -}}
  {{- $stableDeploy := lookup "apps/v1" "Deployment" $scope.Release.Namespace $stableName -}}

  {{- $deployment = mergeOverwrite $deployment $overrides -}}

  {{- toYaml $deployment -}}

  {{- if not $scope.Values.promote | and $stableDeploy }}
---
{{ toYaml $stableDeploy }}
  {{- end }}
{{- end -}}

{{- define "bluegreen.deployment.override.preview" -}}
metadata:
  name: {{ .Release.Name }}-{{ include "bluegreen.preview" . }}
spec:
  selector:
    matchLabels:
      bluegreen: {{ include "bluegreen.preview" . }}
  template:
    metadata:
      labels:
        bluegreen: {{ include "bluegreen.preview" . }}
{{- end -}}
