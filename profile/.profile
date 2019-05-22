#!/usr/bin/env bash

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # set PATH so it includes user's private bin if it exists
    if [ -d "$HOME/bin" ] ; then
        PATH="$HOME/bin:$PATH"
    fi
    if [ -d "$HOME/.local/bin" ] ; then
        PATH="$HOME/.local/bin:$PATH"
    fi

    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
    	source "$HOME/.bashrc"
    fi

    # source local envrioment variables
#    if [ -f ".env" ]; then
#    	source ".env"
#    fi
fi


