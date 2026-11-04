{{- /* Installs the `system: true` tools this host wants, via its package
       manager. Shared by .chezmoiscripts/run_onchange_before_10-packages.sh.tmpl
       and, on the devpod, dot_config/setup/executable_devpod-deps.sh.tmpl,
       which re-runs it on every pod start. Pass the template data as `.`. */ -}}
{{ $fam := .pkgfamily -}}
{{ $pm := dig $fam (dict) .packagemanagers -}}
{{/* Tools this host wants: everything without a `hosts` list, plus the ones
     naming it. Kept whole, because a mise-managed tool can still be the
     reason a system package is needed (nvim needs cc). */}}
{{- $tools := list }}
{{- range .tools }}
{{-   if or (not (hasKey . "hosts")) (has $.host .hosts) }}{{ $tools = append $tools . }}{{ end }}
{{- end }}

# Host: {{ .host }}   osid: {{ .osid }}   packages: {{ $fam | default "unknown -- no package manager" }}
PM={{ dig "name" "" $pm | quote }}
{{ if hasKey $pm "refresh" -}}
refresh_pkgs() { {{ $pm.refresh }}; }
{{- else -}}
refresh_pkgs() { :; }
{{- end }}
{{ if hasKey $pm "install" -}}
install_pkgs() { {{ $pm.install }} "$@"; }
{{- else -}}
install_pkgs() { :; }
{{- end }}

# cmd|package|what needs it|shell test for "installed", if not `command -v cmd`
DEPS="
{{- range $tools }}
{{- $cask := and (hasKey . "cask") (eq $fam "brew") -}}
{{- if and (dig "system" false .) (not $cask) }}
{{ .cmd }}|{{ if hasKey . "pkg" }}{{ dig $fam (dig "default" .cmd .pkg) .pkg }}{{ else }}{{ .cmd }}{{ end }}|{{- $c := .cmd }}{{ $needs := list }}{{ range $tools }}{{ if has $c (dig "deps" (list) .) }}{{ $needs = append $needs .cmd }}{{ end }}{{ end }}{{ join ", " $needs }}|{{ dig "check" "" . }}
{{- end }}
{{- end }}
"
have_cmd() { command -v "$1" >/dev/null 2>&1; }

# Space-separated, not an array: /bin/bash on macOS is 3.2, where an empty
# array under `set -u` is an error.
missing=""
while IFS='|' read -r cmd pkg needs check; do
  [ -z "$cmd" ] && continue
  if [ -n "$check" ]; then
    sh -c "$check" >/dev/null 2>&1 && continue
  else
    have_cmd "$cmd" && continue
  fi
  echo "missing: $cmd${needs:+ (needed by $needs)}"
  missing="$missing $pkg"
done <<DEPS_EOF
$DEPS
DEPS_EOF

if [ -n "$missing" ]; then
  if [ -n "$PM" ]; then
    echo "Installing via $PM:$missing"
    refresh_pkgs
    install_pkgs $missing
  else
    echo "No package manager known for this machine; install by hand:$missing" >&2
    echo "To teach chezmoi about it, add its ID to \$pkgfamily in .chezmoi.toml.tmpl" >&2
    echo "and a packagemanagers entry in .chezmoidata/packages.yaml." >&2
  fi
fi
