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

  {{- toYaml $orderedList }}
{{- end -}}

{{- define "example.mergesort.merge" -}}
  {{- $firstList  := index . 0 -}}
  {{- $secondList := index . 1 -}}
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
      {{- if le $firstElement $secondElement -}}
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

{{- define "example.mergesort" -}}
  {{- $unorderedList := . -}}
  {{- $orderedList := list -}}

  {{- if lt (len $unorderedList) 2 -}}
    {{- $orderedList = $unorderedList -}}
  {{- else -}}
    {{- $middleIndex := div (len $unorderedList) 2 -}}
    {{- $firstHalf := slice $unorderedList 0 $middleIndex -}}
    {{- $secondHalf := slice $unorderedList $middleIndex -}}

    {{- $firstSorted := include "example.mergesort" $firstHalf | fromYamlArray -}}
    {{- $secondSorted := include "example.mergesort" $secondHalf | fromYamlArray -}}
    {{- $orderedList = include "example.mergesort.merge" (list $firstSorted $secondSorted) | fromYamlArray -}}
  {{- end -}}

  {{- toYaml $orderedList }}
{{- end -}}
