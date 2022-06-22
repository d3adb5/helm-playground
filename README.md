# Helm Charts Playground

This repository shall contain whatever interesting thing jumps out at me when
I'm handling Helm charts here and there. It has no main focus or intent, so
don't call this a project.

# Partial templates as functions

This understanding might apply to Go's template packages overall, but since this
repository explores Helm's capabilities, we'll speak in terms of Helm's partial
templates instead.

While implementing functions you can invoke in your templates isn't possible
through Helm, we can somewhat recreate them by defining partial templates and
making use of the limited type system that is available through the YAML spec.

This is how we recreate functions:

1. The function's name is the name of our partial template.
2. Arguments are given through the template's scope.
3. The function's return value is the text the template generates.
4. Typing is loose, and there is no static typing.
5. Parsing is made necessary if our return type is not string. 

When it comes to the funciton arguments:

1. A single argument can just be passed as the scope.
2. Positional arguments can be given as a list using the `list` constructor.
3. Named arguments can be given as a dict using the `dict` constructor.

It kinda sucks that for positional arguments you'll be using `index` quite a
bit: `index . 0`, `index . 123`. I recommend assigning values to variables:

```yaml
{{- $name := index . 0 -}}
{{- $age := index . 1 | int64 -}}
```

## Examples

Since there can't be true polymorphism, this is an attempt at an identity
function that works for any YAML object:

```yaml
{{- define "identity" -}}
  {{- toYaml . -}}
{{- end -}}

# This is how you use it:
myValues:
  {{- include "identity" .Values.someValue | nindent 2 }}

# We have to convert back from YAML to use the value as a dict
{{- if get (include "identity" .Values.someValue | fromYaml) "someKey" | eq "someString" -}}
anotherKey: "Why are you using an identity function in an if?"
{{- end -}}
```

Note that the identity function here is just `toYaml`, since we're bound to
parse YAML in the end to get actual data in our templates. Haskell programmers
rejoice, every type in YAML or that you can use with these functions in theory
has an instance for the `Read` typeclass.

This is a perhaps more interesting function that deals with numbers:

```yaml
{{- define "fibonacci" -}}
  {{- if lt . 2 -}}
    {{- printf "1" -}} # No "return" statement, sadly!
  {{- else -}}
    {{- $twoBefore := include "fibonacci" (sub . 2) | int64 -}}
    {{- $oneBefore := include "fibonacci" (sub . 1) | int64 -}}
    {{- add $twoBefore $oneBefore | printf "%s" -}}
  {{- end -}}
{{- end -}}
```

In taking a page from Oracle's book on writing documentation that is totally up
to date, I haven't tested this function, but from the looks of it it should
work. You get the picture.

## Sorting

You'll see in this repository implementations for the quick sort and merge sort
algorithms written as Helm partial templates. You can give it a comparison
"function" to get the ordering that you want: sort objects by a given property,
sort integers by parity, you name it. As long as your partial template yields
one of the following:

1. `LT`, for "less than".
2. `EQ`, for "equal".
3. `GT`, for "greater than".

Example usage lies in the `example-application` chart.
