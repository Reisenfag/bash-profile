#!/usr/bin/env bash

# If not running interactively, don't do anything
if [[ $- != *i* ]]; then
    return
fi

# Message in terminal title
echo -ne "\033]0;Loading...\007"

# immediately writes and reads history in file and removes duplicate commands
__clean_history() {
    # exit, if it non user command
    case "$BASH_COMMAND" in
        *\033[*)
            return
        ;;
        _*)
            return
        ;;
    esac

    history -a

    if [ -f "$HISTFILE" ]; then
        HISTTEMP="$(tac "$HISTFILE")"
        echo "$HISTTEMP" | sed "s/ *$//" | awk '!seen[$0]++' | tac > "$HISTFILE"
    fi
    HISTFILE="$(__set_history_file)"

    history -c
    history -r
}

# set local history
__set_history_file() {
    if [ -w "$(pwd)" ]; then
        DIR="$(pwd)"
    else
        DIR="$HOME/.bash.d/history/$(pwd)"
        if [ ! -d "$DIR/$(pwd)" ]; then
            mkdir -p "$DIR/$(pwd)"
            if [ -f "$DIR/.bash_history" ]; then
                touch "$DIR/.bash_history"
            fi
        fi
    fi
    echo "$DIR/.bash_history"
}

# dynamic title for graphical terminals
__show_command_in_title() {
    # exit, if it non user command
    case "$BASH_COMMAND" in
        *\033]0*)
            return
        ;;
        _*)
            return
        ;;
    esac

    echo -ne "\033]0;${USER}@${HOSTNAME}: ${BASH_COMMAND}\007"
}

# promt always starts with a new line
__smart_prompt() {
    # exit, if it non user command
    case "$BASH_COMMAND" in
        \e[6n*)
            return
        ;;
        _*)
            return
        ;;
        *read*)
            return
        ;;
    esac
    # exit, if it mc terminal
    [ -n "$MC_TMPDIR" ] && return
    [ -n "$TERM_PROGRAM" ] && return

    fetch_cursor_position() {
      local pos
      IFS='[;' read -p $'\e[6n' -d R -a pos -rs || echo "failed with error: $? ; ${pos[*]}"
      echo "${pos[2]}"
    }
    col="$(fetch_cursor_position)"

    if [ $col -gt 1 ]; then
        echo ""
    fi
}


# keybindings
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'


# aliases
alias ls='ls --color=auto'

# history settings
HISTFILE="$(__set_history_file)"
HISTSIZE=10000
HISTFILESIZE=10000
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE='ls:cd:bg:fg:history'


# custom prompt
PROMPT_DIRTRIM=4
if [ "$UID" -eq "0" ]; then
    PS1="\[\e[1;31m\]\u@"
elif [ "$UID" -eq "1000" ]; then
    PS1="\[\e[1;32m\]\u@"
else
    PS1="\[\e[1;33m\]\u@"
fi
if [ -n "$SSH_TTY" ]; then
    PS1="\[\e[1;36m\]ssh:$PS1\H"
    TITLE="\u@\H\a"
else
    PS1="$PS1\H"
    TITLE="\u@\H\a"
fi
PS1="$PS1\[\e[1;37m\]:\[\e[1;34m\]\w\[\e[m\]\n\[\e[1;37m\]>>\[\e[m\] "
PS2="\[\e[1;90m\]->\[\e[m\] "
PROMPT_COMMAND="__smart_prompt;__clean_history;$PROMPT_COMMAND"


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
        trap __show_command_in_title DEBUG
    ;;
    *)
    ;;
esac

# Message in terminal title
echo -ne "\033]0;${USER}@${HOSTNAME}\007"

