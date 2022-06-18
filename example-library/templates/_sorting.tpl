{{/* Attempts at sorting lists directly through Helm! */}}

{{- define "example.quicksort" -}}
  {{- $unorderedList := . -}}
  {{- $orderedList := list -}}

  {{- if lt (len .) 2 -}}
    {{- $orderedList = $unorderedList -}}
  {{- else -}}
    {{- $pivot := first $unorderedList -}}
    {{- $rest := rest $unorderedList -}}
    {{- $left := list -}}
    {{- $right := list -}}

    {{- range $rest -}}
      {{- if lt . $pivot -}}
        {{- $left = append $left . -}}
      {{- else -}}
        {{- $right = append $right . -}}
      {{- end -}}
    {{- end -}}

    {{- $left = include "example.quicksort" $left | fromYamlArray | default list -}}
    {{- $right = include "example.quicksort" $right | fromYamlArray | default list -}}
    {{- $orderedList = concat $left (list $pivot) $right -}}
  {{- end -}}

{{ range $orderedList -}}
- {{ toYaml . }}
{{ end -}}

{{- end -}}
