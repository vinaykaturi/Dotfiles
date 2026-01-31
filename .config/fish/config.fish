if status is-interactive
# Commands to run in interactive sessions can go here
set -U fish_greeting
fastfetch -c /usr/share/fastfetch/presets/examples/12.jsonc

alias ls="eza -lh"
alias la="eza -alh"
alias cls="clear"

end
