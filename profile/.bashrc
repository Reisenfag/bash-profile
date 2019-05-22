#!/usr/bin/env bash

# external tools activation
__external_tools() {
    # Pyenv activation
    # set PATH so it includes pyenv's private bin if it exists
    if [ -d "$HOME/.pyenv" ] ; then
        export PYENV_ROOT="$HOME/.pyenv"
        PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"
        eval "$(pyenv virtualenv-init -)"
    fi
#    if [ -e "venv" ]; then
#        # Check to see if already activated to avoid redundant activating
#        if [ "$VIRTUAL_ENV" != "$(pwd -P)/venv" ]; then
#            source venv/bin/activate
#            _OLD_VIRTUAL_PS1="$PS1"
#            PS1="(venv) $PS1"
#            export PS1
#        fi
#    fi
}

# If not running interactively, don't do anything
if [[ $- != *i* ]]; then
    __external_tools
    return
fi

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
    histmp="$(tac "$HISTFILE")"
    echo "$histmp" | sed "s/ *$//" | awk '!seen[$0]++' | tac > "$HISTFILE"
    history -c
    history -r
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

    if [ -n "${SSH_TTY}" ]; then
        TITLE="${USER}@${HOSTNAME}: ${BASH_COMMAND}"
    else
        TITLE="${USER}@${HOSTNAME}: ${BASH_COMMAND}"
    fi
    echo -ne "\033]0;$TITLE\007"
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
PS1="\[\e]0;$TITLE\]$PS1\[\e[1;37m\]:\[\e[1;34m\]\w\[\e[m\]\n\[\e[1;37m\]>>\[\e[m\] "
PS2="\[\e[1;90m\]->\[\e[m\] "
PROMPT_COMMAND="__smart_prompt;__clean_history;$PROMPT_COMMAND"
#PROMPT_COMMAND="__clean_history;$PROMPT_COMMAND"

# activate external tools
__external_tools

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

