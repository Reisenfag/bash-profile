#!/usr/bin/env bash

# change working dir
if [[ -x "$(command -v xdg-user-dir)" && -d "$(xdg-user-dir DESKTOP)" ]]; then
    export DEFAULT_DIR=$(xdg-user-dir DESKTOP)
    cd "$DEFAULT_DIR"
elif [ -d "$HOME/desk" ]; then
    export DEFAULT_DIR="$HOME/desk"
    cd "$DEFAULT_DIR"
fi


# include .profile if it exists or .bashrc if it exists
if [ -f "$HOME/.profile" ]; then
    . "$HOME/.profile"
elif [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

