source ~/.bash_aliases
source ~/.env_secret

export ANDROID_SDK_ROOT="/usr/local/share/android-sdk"
export ANDROID_HOME=$ANDROID_SDK_ROOT
export PATH=$PATH:$ANDROID_SDK_ROOT/tools:/usr/local/opt/postgresql\@10/bin:/Users/omar/code/flutter/bin
export BASH_SILENCE_DEPRECATION_WARNING=1

# terminal window title
export PROMPT_COMMAND='echo -ne "\033]0;$PWD\007"'

# git bash prompt
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\u@\h \[\033[32m\]\w\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "

source /usr/local/opt/chruby/share/chruby/chruby.sh
source /usr/local/opt/chruby/share/chruby/auto.sh
chruby 2.6.5

ssh-add --apple-use-keychain

export EDITOR=vi
export PAGER=less

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm use 16

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
