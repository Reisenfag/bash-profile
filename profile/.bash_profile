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

