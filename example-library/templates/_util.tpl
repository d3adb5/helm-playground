{{/* Utility functions I don't know where to put. */}}

{{/*
  Perform a binary search on a given list to find the index of a given element
  recursively.

  Takes a list containing the element to search for and the dataset (list).

  Subject to Helm's recursion stack limit of 1000. :(
*/}}

{{- define "example.binary-search" -}}
  {{- $needle := index . 0 -}}
  {{- $hstack := index . 1 -}}

  {{- if empty $hstack | not -}}
    {{- $middle := div (len $hstack) 2 -}}
    {{- if eq $needle (index $hstack $middle) -}}
      {{- $middle -}}
    {{- else if lt $needle (index $hstack $middle) -}}
      {{- $left := slice $hstack 0 $middle -}}
      {{- include "example.binary-search" (list $needle $left) -}}
    {{- else -}}
      {{- $right := slice $hstack $middle -}}
      {{- $offset := include "example.binary-search" (list $needle $right) | int -}}
      {{- add $middle $offset -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
