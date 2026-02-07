#!/bin/bash

get_os() { grep "PRETTY_NAME" /etc/os-release | cut -d '"' -f2; }
get_kernel() { uname -r; }
get_model() { cat /sys/class/dmi/id/product_name; }
get_version() { cat /sys/class/dmi/id/product_version; }
get_uptime() { uptime -p | sed 's/up //'; }
get_shell() { $SHELL --version | head -1 | sed "s/, version/ /"; }
get_term() { $TERM --version | awk '{ print $1, $2}'; }
get_cpu() { lscpu | grep 'Model name:' | cut -d":" -f2 |  xargs; }
get_mem() { free -h | grep "Mem:" | xargs | awk '{print $3" / "$2}' | sed "s/Gi/ GB/g"; }
get_packages() { pacman -Q | wc -l; }
get_wm() { 
    if [ -n "$WAYLAND_DISPLAY" ]; then
        echo "$XDG_CURRENT_DESKTOP (Wayland)"
    elif [ -n "$DISPLAY" ]; then
         WM=$(wmctrl -m | head -n1 | awk '{print $1}')
         echo $WM
    else
        echo "Unknown"
    fi

}

echo "  OS:        -> $(get_os)"
echo "  Machine:   -> $(get_model) ($(get_version))" 
echo "  Kernel:    -> $(get_kernel)"
echo "  Uptime:    -> $(get_uptime)"
echo "  WM:        -> $(get_wm)"
echo "  Shell:     -> $(get_shell)"
echo "  Terminal:  -> $(get_term)"
echo "  CPU:       -> $(get_cpu)"
echo "  Memory:    -> $(get_mem)"
echo "  Packages:  -> $(get_packages)"
