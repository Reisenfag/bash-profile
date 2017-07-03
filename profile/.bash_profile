__path_prepend() {
    PATH=${PATH//":$1:"/:}     # delete all instances in the middle
    PATH=${PATH/%":$1"/}       # delete any instance at the end
    PATH=${PATH/#"$1:"/}       # delete any instance at the beginning
    if [ -d "$1" ]; then
        PATH="$1${PATH:+":$PATH"}" # prepend $1 or if $PATH is empty set to $1
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

# include .profile if it exists
if [ -f "$HOME/.profile" ]; then
    . "$HOME/.profile"
fi

