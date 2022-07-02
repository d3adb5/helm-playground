{{/*
  Partial template that runs a given Brainfuck program, outputting solely the
  machine's output.
*/}}

{{- define "bfck.run" -}}
  {{- $currentOperator := index .program (int .pctr) | include "example.char" -}}
  {{- $modifiedMachine := include "bfck.apply" (list $currentOperator .) | fromYaml -}}
  {{- $incrementedPCtr := set $modifiedMachine "pctr" (add1 .pctr) -}}
  {{- if lt (int $incrementedPCtr.pctr) (len .program) -}}
    {{- include "bfck.run" $incrementedPCtr -}}
  {{- else -}}
    {{- $modifiedMachine.output -}}
  {{- end -}}
{{- end -}}
