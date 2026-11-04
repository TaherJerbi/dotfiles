#!/usr/bin/env bash
# Claude Code status line: session info, then context and plan-limit meters.

input=$(cat)

dir=$(jq -r '.workspace.current_dir // .cwd' <<<"$input")
branch=$(git -C "$dir" --no-optional-locks branch --show-current 2>/dev/null)
if [[ -n $branch ]] && [[ -n $(git -C "$dir" --no-optional-locks status --porcelain 2>/dev/null | head -1) ]]; then
  branch+="*"
fi

jq -r --arg branch "$branch" '
  def color(p): if p >= 90 then "\u001b[31m" elif p >= 70 then "\u001b[33m" else "\u001b[32m" end;
  def dim: "\u001b[2m" + . + "\u001b[0m";
  def pct(p): "\(color(p))\(p)%\u001b[0m";
  def k: if . >= 1000 then "\(. / 1000 | round)k" else tostring end;
  def limit(name; l; fmt):
    if l.used_percentage == null then empty
    else "\(name) \(pct(l.used_percentage | floor))" + (" - " + (l.resets_at | localtime | strftime(fmt)) | dim)
    end;

  ((.workspace.current_dir // .cwd | split("/") | last)
   + (if $branch != "" then " " + ($branch | dim) else "" end)
   + " · " + ([.model.display_name, .effort.level] | map(select(. != null)) | join(" · ")))
  + " | " +
  ([ (.context_window as $c
      | "ctx " + ("\($c.total_input_tokens // 0 | k)/\($c.context_window_size | k)" | dim)
        + " " + pct($c.used_percentage // 0 | floor)),
     limit("5h"; .rate_limits.five_hour // {}; "%H:%M"),
     limit("7d"; .rate_limits.seven_day // {}; "%a")
   ] | join(" · "))
' <<<"$input"
