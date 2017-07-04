#!/usr/bin/env bash

# fancy terminal
if [ -n "$COLORTERM" ]; then
    if [ -e /lib/terminfo/x/xterm?256color ] || [ -e /usr/share/terminfo/x/xterm?256color ]; then
        TERM=xterm-256color
    else
        TERM=xterm-color
    fi
fi

# include .profile if it exists
if [ -f "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi

# remove dead and dublicated path from $PATH
for check_path in `echo "${PATH//:/$'\n'}" | awk '!seen[$0]++'`; do
    if [ -d "$check_path" ] ; then
        new_path="$new_path:$check_path"
    fi
done
PATH=`echo $new_path | sed "s/^://"`
unset check_path new_path

