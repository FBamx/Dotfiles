export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git
         zsh-autosuggestions
         zsh-syntax-highlighting
         extract
        )

source $ZSH/oh-my-zsh.sh

alias v=vim
alias py=python
alias pnv=pipenv
alias vim=nvim
alias clr=clear
alias ls=logo-ls
alias kc=kubectl
alias kb=kubebuilder
alias proxy=proxy.sh
alias proxy="source ~/proxy.sh"
alias lg=lazygit
. ~/proxy.sh set

export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:~/go/bin
export EDITOR="nvim"
export VISUAL="nvim"
export NVIMRC=~/.config/nvim/init.lua

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# oh-my-posh
# eval "$(oh-my-posh init zsh)"
# eval "$(oh-my-posh init zsh --config ~/jandedobbeleer.omp.json)"

# autojump
# git clone https://github.com/wting/autojump.git
[[ -s ~/.autojump/etc/profile.d/autojump.sh ]] && source ~/.autojump/etc/profile.d/autojump.sh
autoload -U compinit && compinit -u
