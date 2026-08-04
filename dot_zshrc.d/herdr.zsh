# herdr — tmux-like CLI shortcuts (aligned with dot_config/herdr & dot_tmux.conf.tmpl)

# hd / hdr: launch / attach herdr
alias hd='herdr'
alias hdr='herdr'

# c: new tab  (tmux prefix+c)
alias hdc='herdr tab create'
# p/n: previous / next tab  (tmux prefix+p/n)
alias hdp='herdr-tab-prev'
alias hdn='herdr-tab-next'

# k/j/h/l: focus pane up/down/left/right  (tmux prefix+k/j/h/l)
alias hdk='herdr pane focus --direction up'
alias hdj='herdr pane focus --direction down'
alias hdh='herdr pane focus --direction left'
alias hdl='herdr pane focus --direction right'

# s: split down  (tmux prefix+- / ")
alias hds='herdr pane split --direction down'
# v: split right  (tmux prefix+| / %)
alias hdv='herdr pane split --direction right'

# z: zoom toggle  (tmux prefix+z)
alias hdz='herdr pane zoom'
# x: close pane  (tmux prefix+x)
alias hdx='herdr-pane-close'
# sourcehdr: reload config  (tmux prefix+R)
alias sourcehdr='herdr server reload-config'
# st: status
alias hdst='herdr status'

herdr-tab-cycle() {
    local direction="$1" tab_id
    tab_id=$(herdr tab list | python3 -c '
import json, sys
d = json.load(sys.stdin)["result"]["tabs"]
foc = next(t for t in d if t["focused"])
tabs = sorted((t for t in d if t["workspace_id"] == foc["workspace_id"]),
              key=lambda t: t["number"])
i = next(i for i, t in enumerate(tabs) if t["tab_id"] == foc["tab_id"])
k = (i + 1) % len(tabs) if sys.argv[1] == "next" else (i - 1) % len(tabs)
print(tabs[k]["tab_id"])
' "$direction") || return 1
    herdr tab focus "$tab_id"
}

herdr-tab-next() { herdr-tab-cycle next; }
herdr-tab-prev() { herdr-tab-cycle prev; }

herdr-pane-close() {
    local id
    id=$(herdr pane current | python3 -c '
import json, sys
print(json.load(sys.stdin)["result"]["pane"]["pane_id"])
') || return 1
    herdr pane close "$id"
}
