
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

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