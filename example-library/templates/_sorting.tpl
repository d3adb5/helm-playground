{{/* Attempts at sorting lists directly through Helm! */}}

{{- define "example.compare.default" -}}
  {{- if lt (index . 0) (index . 1) -}}
    {{- printf "LT" -}}
  {{- else if eq (index . 0) (index . 1) -}}
    {{- printf "EQ" -}}
  {{- else -}}
    {{- printf "GT" -}}
  {{- end -}}
{{- end -}}

{{- define "example.quicksort.gen" -}}
  {{- $unorderedList := index . 0 -}}
  {{- $comparePartial := index . 1 -}}
  {{- $orderedList := list -}}

  {{- if lt (len $unorderedList) 2 -}}
    {{- $orderedList = $unorderedList -}}
  {{- else -}}
    {{- $pivot := first $unorderedList -}}
    {{- $rest := rest $unorderedList -}}
    {{- $left := list -}}
    {{- $right := list -}}

    {{- range $rest -}}
      {{- if include $comparePartial (list . $pivot) | eq "LT" -}}
        {{- $left = append $left . -}}
      {{- else -}}
        {{- $right = append $right . -}}
      {{- end -}}
    {{- end -}}

    {{- $left = include "example.quicksort.gen" (list $left $comparePartial) | fromYamlArray -}}
    {{- $right = include "example.quicksort.gen" (list $right $comparePartial) | fromYamlArray -}}
    {{- $orderedList = concat $left (list $pivot) $right -}}
  {{- end -}}

  {{- toYaml $orderedList }}
{{- end -}}

{{- define "example.mergesort.merge" -}}
  {{- $firstList  := index . 0 -}}
  {{- $secondList := index . 1 -}}
  {{- $comparePartial := index . 2 -}}
  {{- $mergedList := list -}}

  {{- /* Used to control what to do when we have exhausted a list. */ -}}
  {{- $firstEndReach := true -}}

  {{- range $i := until (add (len $firstList) (len $secondList) | int) -}}
    {{- if or (empty $firstList) (empty $secondList) -}}
      {{- if $firstEndReach -}}
        {{- $mergedList = concat $mergedList $firstList $secondList -}}
        {{- $firstEndReach = false -}}
      {{- end -}}
    {{- else -}}
      {{- $firstElement  := first $firstList -}}
      {{- $secondElement := first $secondList -}}
      {{- if include $comparePartial (list $firstElement $secondElement) | eq "LT" -}}
        {{- $mergedList = append $mergedList $firstElement -}}
        {{- $firstList = rest $firstList -}}
      {{- else -}}
        {{- $mergedList = append $mergedList $secondElement -}}
        {{- $secondList = rest $secondList -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- toYaml $mergedList }}
{{- end -}}

{{- define "example.mergesort.gen" -}}
  {{- $unorderedList := index . 0 -}}
  {{- $comparePartial := index . 1 -}}
  {{- $orderedList := list -}}

  {{- if lt (len $unorderedList) 2 -}}
    {{- $orderedList = $unorderedList -}}
  {{- else -}}
    {{- $middleIndex := div (len $unorderedList) 2 -}}
    {{- $firstHalf := slice $unorderedList 0 $middleIndex -}}
    {{- $secondHalf := slice $unorderedList $middleIndex -}}

    {{- $firstSorted := include "example.mergesort.gen" (list $firstHalf $comparePartial) | fromYamlArray -}}
    {{- $secondSorted := include "example.mergesort.gen" (list $secondHalf $comparePartial) | fromYamlArray -}}
    {{- $orderedList = include "example.mergesort.merge" (list $firstSorted $secondSorted $comparePartial) | fromYamlArray -}}
  {{- end -}}

  {{- toYaml $orderedList }}
{{- end -}}

{{/*
  These functions just invoke the "general" sorting functions with the default
  comparison function, which uses Helm's "lt".
*/}}

{{- define "example.quicksort" -}}
  {{- include "example.quicksort.gen" (list . "example.compare.default") -}}
{{- end -}}

{{- define "example.mergesort" -}}
  {{- include "example.mergesort.gen" (list . "example.compare.default") -}}
{{- end -}}
