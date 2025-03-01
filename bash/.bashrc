#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Check if there is an existing detached tmux session, otherwise start new one
if [[ -z "$TMUX" ]] && [[ $(hostname) != *toolbox* ]]; then
  tmux -2 attach -t default || tmux -2 new -s default
fi

# FZF mappings and options
if [ -x "$(command -v fzf)" ]; then
  [ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && source /usr/share/doc/fzf/examples/key-bindings.bash
fi

# if kubectl utility is installed
if [ -x "$(command -v kubectl)" ]; then
  source <(kubectl completion bash)
fi

# if z utility is installed
if [ -f '/usr/libexec/z.sh' ]; then
  . /usr/libexec/z.sh
fi

if [[ $(hostname) != *toolbox* ]]; then
  PS1="\[\033[0;31m\]\342\224\214\342\224\200\$([[ \$? != 0 ]] && echo \"[\[\033[0;31m\]\342\234\227\[\033[0;37m\]]\342\224\200\")[$(if [[ ${EUID} == 0 ]]; then echo '\[\033[01;31m\]root\[\033[01;33m\]@\[\033[01;96m\]\h'; else echo '\[\033[0;39m\]\u\[\033[01;33m\]@\[\033[01;96m\]\h'; fi)\[\033[0;31m\]]\342\224\200[\[\033[0;32m\]\w\[\033[0;31m\]]\[\033[0;36m\]\$([[ -n \$(git branch --show-current 2>/dev/null) ]] && echo \" branch: \[\033[01;31m\]\$(git branch --show-current 2>/dev/null)\")\n\[\033[0;31m\]\342\224\224\342\224\200\342\224\200\342\225\274 \[\033[0m\]\[\e[01;33m\]\\$\[\e[0m\]"
fi

# Turn on parallel history
shopt -s histappend
# Set the maximum number of lines in the history file
export HISTFILESIZE=100000
# Set the maximum number of commands to remember in the session history
export HISTSIZE=100000
# Ignore duplicate commands and commands starting with a space
export HISTCONTROL=ignoreboth
# Update the history file after every command
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
# Turn on checkwinsize
shopt -s checkwinsize

# If keychain is installed add id_syslq key
if [ -x "$(command -v keychain)" ]; then
  function key(){
    eval $(keychain -q --eval ~/.ssh/keys/id_syslq)
  }
fi

# If aspell is installed define spellcheck function
if [ -x "$(command -v aspell)" ]; then
  function sc(){
    echo "$1" | aspell -a | cut -d ':' -f 2 | cut -d ',' -f 1 | grep -v 'International' | xargs wl-copy
  }
fi

# If docker is installed define dcupdate function
if [ -x "$(command -v docker)" ] && docker compose version >/dev/null 2>&1; then
   function dcupdate() {
       if ! { [ -f docker-compose.yaml ] || [ -f docker-compose.yml ]; }; then
           echo "No docker-compose file found"
           return 1
       fi
       
       docker compose pull && \
       docker compose down && \
       docker compose up -d --build && \
       docker compose ps && \
       docker image prune -f && \
       docker system prune -f
   }
   
   # Function assumes that all docker-compose files are in subdirs within ~/LocalApps
   function dcupdateall() {
       for file in $(find "$(pwd)/LocalApps" -type f -iname "docker-compose.yaml" 2>/dev/null); do pushd "$(dirname "$file")" >/dev/null && dcupdate && popd >/dev/null; done  
   }
fi

# If Buku and fzf are installed, define the openbuku function
if [ -x "$(command -v buku)" ] && [ -x "$(command -v fzf)" ]; then
    function openbuku() {
        url=$(buku -p -f4 | fzf -m --reverse --preview "buku --nostdin -p {1}" --preview-window=wrap | cut -f2)

        if [ -n "$url" ]; then
            echo "$url" | xargs firefox
        else
            echo "No URL selected."
            return 1
        fi
    }
fi

# If steam is installed configure it to use nvidia card
if [ -x "$(command -v steam)" ]; then
  export __NV_PRIME_RENDER_OFFLOAD=1
  export __GLX_VENDOR_LIBRARY_NAME=nvidia
fi

alias ls='ls --color'
alias vim='vi'
alias where='curl ifconfig.co/country'
alias ff='mullvad-exclude /usr/bin/firefox'
alias csnapshot='sudo lvcreate -L20G -s -n lv_root_snapshot_$(date +%Y%m%d_%H%M%S) /dev/vg-syslq-pc/lv_root'
alias rp='systemctl --user restart pipewire'
alias lst='find . -type f -newermt "$(date +%Y-%m-%d)"'
alias ftree='tree -a -I '.git''
alias bp='cd /home/syslq/GitRepos/Buku && git p && cd -'
alias rmount='sudo restic -r /mnt/storage1/ResticBackup mount /mnt/restic'
alias kind='~/LocalApps/kind/kind'
alias argocd='~/LocalApps/argocd/argocd'

export EDITOR='vim'
export PYTHONWARNINGS=ignore buku
