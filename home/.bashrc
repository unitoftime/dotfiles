# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin:~/git/goroot/misc/wasm
export GOPRIVATE="github.com/unitoftime/*"
#export VST_PATH="/nix/var/nix/profiles/system/sw/lib/vst"

export EDITOR="ted"

# User-installed tools (pipx, Antigravity CLI)
export PATH="$HOME/.local/bin:$PATH"

# Settings kept out of the public repo (from ~/git/dotfiles/private/home).
[ -f ~/.bashrc.local ] && . ~/.bashrc.local
