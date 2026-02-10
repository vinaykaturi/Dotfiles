#!/bin/bash

get_os() { grep "PRETTY_NAME" /etc/os-release | cut -d '"' -f2; }
get_kernel() { uname -r; }
get_model() { cat /sys/class/dmi/id/product_name; }
get_version() { cat /sys/class/dmi/id/product_version; }
get_uptime() {
    local up_seconds=$(awk '{print int($1)}' /proc/uptime)
    local days=$((up_seconds / 86400))
    local hours=$(((up_seconds % 86400) / 3600))
    local minutes=$(((up_seconds % 3600) / 60))
    echo "${days}days, ${hours}hours, ${minutes}minutes"
}   
get_shell() { $SHELL --version | head -1 | sed "s/, version/ /"; }
get_term() { $TERM --version | awk '{ print $1, $2}'; }
get_cpu() { lscpu | grep 'Model name:' | cut -d":" -f2 |  xargs; }
get_mem() { free -h | grep "Mem:" | xargs | awk '{print $3" / "$2}' | sed "s/Gi/ GB/g"; }
get_packages() { pacman -Q | wc -l; }
get_wm() { 
    if [ -n "$WAYLAND_DISPLAY" ]; then
        WM=$($XDG_CURRENT_DESKTOP --version | awk '{ print $1, $2}')
        echo "$WM (Wayland)"
    elif [ -n "$DISPLAY" ]; then
         WM=$(wmctrl -m | head -n1 | awk '{print $1}')
         echo $WM
    else
        echo "Unknown"
    fi
}
get_resolution() { 
    if command -v wlr-randr >/dev/null; then
        #Res=$(wlr-randr | grep "current" | xargs | awk '{print $1}')
        #Rate=$(wlr-randr | grep "current" | xargs | awk '{print $3}' | cut -d"." -f1)
        #echo "${Res}px @ ${Rate}Hz"
        wlr-randr | grep "current" | xargs | awk '{print $1"px @ " int($3)"Hz"}'
    else
        Res=$(cat /sys/class/drm/*/modes | head -n 1)
        echo "${Res}px"
    fi
}

echo "  OS:          -> $(get_os)"
echo "  Machine:     -> $(get_model) ($(get_version))" 
echo "  Kernel:      -> $(get_kernel)"
echo "  Uptime:      -> $(get_uptime)"
echo "  Resolution:  -> $(get_resolution)"
echo "  WM:          -> $(get_wm)"
echo "  Shell:       -> $(get_shell)"
echo "  Terminal:    -> $(get_term)"
echo "  CPU:         -> $(get_cpu)"
echo "  Memory:      -> $(get_mem)"
echo "  Packages:    -> $(get_packages)"
