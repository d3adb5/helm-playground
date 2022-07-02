{{/*
  Brainfuck operators, implemented as partial templates in Helm. These
  functions will take as input a Brainfuck machine and output a new Brainfuck
  machine, with modifications done to it if need be.
*/}}

{{- define "bfck.apply" -}}
  {{- $operatorToFunc := dict
        ">" "bfck.next"
        "<" "bfck.prev"
        "+" "bfck.inc"
        "-" "bfck.dec"
        "," "bfck.get"
        "." "bfck.put"
        "[" "bfck.start-loop"
        "]" "bfck.end-loop"
  -}}
  {{- include (get $operatorToFunc (index . 0)) (index . 1) -}}
{{- end -}}

{{- define "bfck.next" -}}
  {{- if eq (int .cptr) (sub (len .cells) 1) -}}
    {{- $_ := append .cells 0 | set . "cells" -}}
  {{- end -}}
  {{- add1 .cptr | set . "cptr" | toYaml -}}
{{- end -}}

{{- define "bfck.prev" -}}
  {{- if eq (int .cptr) 0 -}}
    {{- prepend .cells 0 | set . "cells" | toYaml -}}
  {{- else -}}
    {{- sub .cptr 1 | set . "cptr" | toYaml -}}
  {{- end -}}
{{- end -}}

{{- define "bfck.inc" -}}
  {{- $left := slice .cells 0 (int .cptr) -}}
  {{- $right := slice .cells (add1 .cptr) -}}
  {{- concat $left (list (add1 (index .cells (int .cptr)))) $right | set . "cells" | toYaml -}}
{{- end -}}

{{- define "bfck.dec" -}}
  {{- $left := slice .cells 0 (int .cptr) -}}
  {{- $right := slice .cells (add1 .cptr) -}}
  {{- concat $left (list (sub (index .cells (int .cptr)) 1)) $right | set . "cells" | toYaml -}}
{{- end -}}

{{- define "bfck.get" -}}
{{- end -}}

{{- define "bfck.put" -}}
{{- end -}}

{{- define "bfck.start-loop" -}}
{{- end -}}

{{- define "bfck.end-loop" -}}
{{- end -}}
