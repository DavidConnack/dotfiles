eval "$(/opt/homebrew/bin/brew shellenv)"
export ZSH=$HOME/.oh-my-zsh

export PATH="/opt/homebrew/opt/python@3.13/libexec/bin:$PATH"

ZSH_THEME="robbyrussell"
plugins=(git kubectl)
if [[ -z $ZED_TERM && -t 1 ]]; then
  plugins+=('tmux')
  ZSH_TMUX_AUTOSTART=true
fi

source $ZSH/oh-my-zsh.sh

# bash-style completions (must come after oh-my-zsh's compinit)
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform
complete -o nospace -C /opt/homebrew/bin/terragrunt terragrunt

export EDITOR='vim'

function ncd(){
  local path=""
  for ((i=1;i<=$1;i++)); do
    path="../$path"
  done
  echo "Moving to $path" >&2
  cd "$path"
}

alias ipv4='curl https://ipv4.icanhazip.com'
alias ipv6='curl https://ipv6.icanhazip.com'
alias dotfiles='cd ~/Documents/Repos/dotfiles/'
alias bu='brew update && brew upgrade && brew upgrade --cask --greedy && brew autoremove'
alias wgu='wg-quick up ~/.wg.conf'
alias wgd='wg-quick down ~/.wg.conf'

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
