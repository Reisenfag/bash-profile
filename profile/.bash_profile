#!/usr/bin/env bash

# immediately writes and reads history in file and removes duplicate commands
__clean_history() {
    history -a
    histmp="$( tac $HISTFILE )"
    echo "$histmp" | sed "s/ *$//" | awk '!seen[$0]++' | tac > $HISTFILE
    history -c
    history -r
}

# prompt always starts with a new line
__cursor_correction() {
    exec < /dev/tty
    local oldstty=$(stty -g)
    stty raw -echo min 0
    echo -en "\033[6n" > /dev/tty
    local pos
    IFS=';' read -r -d R -a pos
    stty $oldstty
    col="$((${pos[1]} - 1))"

    if [ $col != 0 ]; then
        echo ""
    fi
}

# fancy terminal
if [ -n "$COLORTERM" ]; then
    if [ -e /lib/terminfo/x/xterm?256color ] || [ -e /usr/share/terminfo/x/xterm?256color ]; then
        TERM=xterm-256color
    else
        TERM=xterm-color
    fi
fi

# include .profile if it exists or .bashrc if it exists
if [ -f "$HOME/.profile" ]; then
    . "$HOME/.profile"
elif [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

# Keybindings
# zsh-like search in history
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# command hook
PROMPT_COMMAND="__clean_history; __cursor_correction; $PROMPT_COMMAND"

# remove dead and dublicated path from $PATH
for check_path in `echo "${PATH//:/$'\n'}" | awk '!seen[$0]++'`; do
    if [ -d "$check_path" ] ; then
        new_path="$new_path:$check_path"
    fi
done
PATH=`echo $new_path | sed "s/^://"`
unset check_path new_path

