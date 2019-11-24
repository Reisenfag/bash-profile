#!/usr/bin/env bash

function history_set_local() {
    __history_clean
    history -c

    CURRENT_DIR="$(pwd)"
    if [ -w "$CURRENT_DIR" ]; then
        DIR="$CURRENT_DIR"
    else
        DIR="$BASH_LOCAL_DIR/history/$CURRENT_DIR"
        if [ ! -d "$DIR/$CURRENT_DIR" ]; then
            mkdir -p "$DIR/$CURRENT_DIR"
        fi
    fi
    FILE="$DIR/$BASH_HISTORY_FILENAME"
    if [ ! -f "$FILE" ]; then
        touch "$FILE"
    fi
    HISTFILE="$FILE"
}
