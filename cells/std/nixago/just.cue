import "strings"
import "text/template"

#Config: {
	head: string | *""
	tasks: [string]: [...string]
}

data: #Config

_final: {
    head: data.head
    tasks: {
        for task, steps in data.tasks {
            "\(task)": strings.Join(steps, "\n    ")
        }
    }
}

tmpl:
"""
{{ .head -}}
{{ range $name, $steps := .tasks }}
{{ $name }}:
    {{ $steps }}
{{- end }}
"""

rendered: template.Execute(tmpl, _final)