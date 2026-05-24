eval "$(/opt/homebrew/bin/brew shellenv)"

source ~/.secret_env

export PATH=/opt/homebrew/opt/openjdk/bin:/Users/tim/.cargo/bin:/opt/homebrew/opt/gnu-sed/libexec/gnubin/:/Users/tim/.local/bin:/Users/tim/code/flutter/bin:$PATH:

export BASH_SILENCE_DEPRECATION_WARNING=1
export DOCKER_HOST="unix://$HOME/.colima/default/docker.sock"

# pyenv
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
pyenv global 3.13

# ruby
source $(brew --prefix)/opt/chruby/share/chruby/chruby.sh
source $(brew --prefix)/opt/chruby/share/chruby/auto.sh
chruby ruby

# append to history
shopt -s histappend

# terminal window title; append to history after each command
PROMPT_COMMAND=('echo -ne "\033]0;$PWD\007"' 'history -a')

# git bash prompt
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "

ssh-add --apple-use-keychain

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
nvm use 26

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export EDITOR=nvim
export PAGER=less

export LESS='--mouse -RFX'

# Have less display colors
# from: https://wiki.archlinux.org/index.php/Color_output_in_console#man
export LESS_TERMCAP_mb=$'\e[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\e[1;33m'     # begin blink
export LESS_TERMCAP_so=$'\e[01;44;37m' # begin reverse video
export LESS_TERMCAP_us=$'\e[01;37m'    # begin underline
export LESS_TERMCAP_me=$'\e[0m'        # reset bold/blink
export LESS_TERMCAP_se=$'\e[0m'        # reset reverse video
export LESS_TERMCAP_ue=$'\e[0m'        # reset underline

export AXES_ENDPOINT=http://localhost:8000
export AXES_TOKEN=24c91e90-df47-485b-a027-ab23ab7edc2d.agUGIw.sJgv-KQaQUATtWgFJesAbwsE9LA

shopt -s expand_aliases
alias vi='nvim'
alias hc='npm run console'
alias fR='kill -USR2 $(cat /Users/omar/code/typetrigger/mobile-client/.pid)'
alias fw='watch "cat .pid | xargs kill -USR1" lib'
alias fr='flutter run --pid-file .pid --flavor dev --target=lib/main_dev.dart'
alias ft='watch "flutter test" lib test'
alias fc='flutter test --coverage && genhtml coverage/lcov.info -o coverage'
alias ft1="while true; do ls -d test/**/* test/* | entr -d ../test_flutter.sh /_; done"
alias sidekiq='bundle exec sidekiq'
alias rake='bundle exec rake'
alias grep='grep --color=auto'
alias ls='ls -G'
alias ll='ls -alG'
alias unplug='diskutil umountDisk /dev/disk2'
alias serve='browser-sync start -s -f . --port 4500'
alias resize='sips -Z 1200 *.JPG'
alias squids-proxy='ssh -D 8123 -f -C -q -N squids'
alias ch='clear; tmux clear-history'
alias tailscale=/Applications/Tailscale.app/Contents/MacOS/Tailscale
alias ip='curl -s https://api.ipify.org'
alias ipinfo='curl -s https://ipinfo.io/json'
alias caf='caffeinate -d'
alias oc='opencode --port 9001'
alias ocr='opencode run'
alias cdb='cd /Users/tim/code/axes/bower'
alias cdc='cd /Users/tim/code/axes/chat-plot'
alias cdd='cd /Users/tim/code/axes/data-catalog'
alias cdf='cd /Users/tim/code/axes/infra'


# Bash Completion for Homebrew
[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"

