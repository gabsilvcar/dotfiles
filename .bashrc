[[ $- != *i* ]] && return

export VISUAL=nvim
export EDITOR="$VISUAL"
export PATH="~/.local/bin:$PATH"

alias ls='ls --color=auto'

PS1='[\u@\h \W]\$ '

if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  exec tmux
fi

