#!/usr/bin/env bash


# immediately writes and reads history in file and removes duplicate commands
__history_clean() {
    history -a
    if [ -f "$HISTFILE" ]; then
        TEMPFILE="$BASH_LOCAL_DIR/$(echo $$).tmp"
        tac "$HISTFILE" > "$TEMPFILE"
        cat "$TEMPFILE" | sed "s/ *$//" | awk '!seen[$0]++' | tac > "$HISTFILE"
    fi
    HISTFILE="$(__history_local_switch)"
    history -c
    history -r
    rm -f "$TEMPFILE"
}


# switch to local history
function __history_local_switch() {
    CURRENT_DIR="$(pwd)"
    FILE_PWD="$CURRENT_DIR/$BASH_HISTORY_FILENAME"
    FILE_LOCAL="$BASH_LOCAL_DIR/history/$CURRENT_DIR/$BASH_HISTORY_FILENAME"
    if [ -f "$FILE_PWD" ]; then
        FILE="$FILE_PWD"
    elif [ -f "$FILE_LOCAL" ]; then
        FILE="$FILE_LOCAL"
    else
        FILE="$HOME/$BASH_HISTORY_FILENAME"
    fi
    echo "$FILE"
}


# dynamic title for graphical terminals
function __title_dynamic() {
    # exit, if it non user command
    [ -n "$bash_loading" ] && return
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
function __prompt_exit_fix() {
    # exit, if it not terminal
    [ -n "$MC_TMPDIR" ] && return
    [ -n "$TERM_PROGRAM" ] && return
    #[ -n "$PIPENV_ACTIVE" ] && echo ""; return

    fetch_cursor_position() {
        local pos
        IFS='[;' \
            read -p $'\e[6n' -d R -a pos -rs || \
            echo "failed with error: $? ; ${pos[*]}"
        echo "${pos[2]}"
    }
    col="$(fetch_cursor_position)"

    if [ $col -gt 1 ]; then
        echo ""
    fi
}


# prepare promt
function __promt_prepare() {
    # exit, if it non user command
    [ -n "$bash_loading" ] && return
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

    __prompt_exit_fix
    __history_clean
}

