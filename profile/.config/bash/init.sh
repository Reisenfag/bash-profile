#!/usr/bin/env bash

export bash_loading=1


BASH_CONFIG_DIR="$HOME/.config/bash"
BASH_LOCAL_DIR="$HOME/.local/share/bash"
BASH_HISTORY_FILENAME=".bash_history"

if [ ! -d "$BASH_LOCAL_DIR" ]; then
    mkdir -p "$BASH_LOCAL_DIR"
fi


source "$BASH_CONFIG_DIR/functions.sh"
source "$BASH_CONFIG_DIR/commands.sh"

# Message in terminal title
echo -ne "\033]0;Loading...\007"


# keybindings
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'


# aliases
alias ls='ls --color=auto'


# history settings
HISTFILE="$(__history_local_switch)"
HISTSIZE=10000
HISTFILESIZE=10000
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE='ls:cd:bg:fg:history'


# custom prompt
PROMPT_DIRTRIM=4
if [ "$UID" -eq "0" ]; then
    newps="\[\e[1;31m\]\u@"
elif [ "$UID" -eq "1000" ]; then
    newps="\[\e[1;32m\]\u@"
else
    newps="\[\e[1;33m\]\u@"
fi
if [ -n "$SSH_TTY" ]; then
    newps="\[\e[1;36m\]ssh:$newps\H"
    TITLE="\u@\H\a"
else
    newps="$newps\H"
    TITLE="\u@\H\a"
fi
newps="$newps\[\e[1;37m\]:\[\e[1;34m\]\w\[\e[m\]\n\[\e[1;37m\]>>\[\e[m\] "
PS1="$newps"
PS2="\[\e[1;90m\]->\[\e[m\] "
#PROMPT_COMMAND="$PROMPT_COMMAND;__promt_prepare"


# remove dead and dublicated path from $PATH
for check_path in `echo "${PATH//:/$'\n'}" | awk '!seen[$0]++'`; do
    if [ -d "$check_path" ] ; then
        new_path="$new_path:$check_path"
    fi
done
PATH=`echo $new_path | sed "s/^://"`
unset check_path new_path

# trap for dynamic title
case "$TERM" in
    xterm*|rxvt*)
        trap __promt_prepare DEBUG
    ;;
    *)
    ;;
esac

# Message in terminal title
echo -ne "\033]0;${USER}@${HOSTNAME}\007"

unset newps check_path new_path bash_loading

