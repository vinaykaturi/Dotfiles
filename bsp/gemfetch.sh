#!/bin/bash

# --- Color Palette ---
C_LABEL='\033[38;5;33m'   
C_ACCENT='\033[38;5;170m' 
C_RESET='\033[0m'
BOLD='\033[1m'

# --- Logic Functions ---

get_os() {
    [[ -f /etc/os-release ]] && source /etc/os-release
    echo "${PRETTY_NAME:-Linux}" | tr -d '"'
}

get_packages() {
    # Arch Linux specific (pacman)
    if command -v pacman >/dev/null; then
        pacman -Q | wc -l
    else
        echo "Unknown"
    fi
}

get_mem() {
    # Fetches Used, Total, and calculates Percentage
    # We convert Gi to GB by using a simple sed replacement
    free -m | awk 'NR==2{
        printf "%.1fGB / %.1fGB (%d%%)", $3/1024, $2/1024, $3*100/$2
    }'
}

get_res() {
    local res=$(cat /sys/class/drm/card*-*/modes 2>/dev/null | head -n1)
    echo "${res:-Unknown}"
}

get_wm_ver() {
    if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
        echo "Hyprland $(Hyprland --version | awk 'NR==1{print $3}')"
    elif [ -n "$NIRI_SOCKET" ]; then
        # Niri version check
        echo "Niri $(niri --version | awk '{print $2}')"
    else
        echo "${XDG_CURRENT_DESKTOP:-Unknown}"
    fi
}

get_shell_ver() {
    # Works for fish, bash, zsh
    $SHELL --version | head -n1 | awk '{print $1, $3}'
}

get_term_ver() {
    # Alacritty version check
    local term_bin=$(ps -p $(ps -p $PPID -o ppid=) -o comm=)
    local term_ver=$($term_bin --version 2>/dev/null | awk '{print $2}')
    echo "${term_bin} ${term_ver}"
}

# --- Data Collection ---
os=$(get_os)
pkgs=$(get_packages)
memory=$(get_mem)
resolution=$(get_res)
wm=$(get_wm_ver)
shell=$(get_shell_ver)
terminal=$(get_term_ver)
uptime=$(awk '{d=int($1/86400); h=int(($1%86400)/3600); m=int(($1%3600)/60); printf "%dd %dh %dm", d, h, m}' /proc/uptime)
cpu=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | xargs)
gpu=$(lspci | awk -F ': ' '/VGA|3D/ {print $2}' | cut -d'[' -f2 | cut -d']' -f1 | head -n1)

# --- Display ---
echo -e "  ${C_ACCENT}${BOLD}󱓞 smplfetch${C_RESET}"
echo -e "  ${C_ACCENT}──────────${C_RESET}"
echo -e "  ${C_LABEL}󰣇 OS      ${C_RESET} $os"
echo -e "  ${C_LABEL}󰏖 PKGS    ${C_RESET} $pkgs"
echo -e "  ${C_LABEL}󱘖 UPTIME  ${C_RESET} $uptime"
echo -e "  ${C_LABEL}󰍹 RES     ${C_RESET} $resolution"
echo -e "  ${C_LABEL}󱡴 WM      ${C_RESET} $wm"
echo -e "  ${C_LABEL}󰞷 SHELL   ${C_RESET} $shell"
echo -e "  ${C_LABEL}󰆍 TERM    ${C_RESET} $terminal"
echo -e "  ${C_LABEL} CPU     ${C_RESET} $cpu"
echo -e "  ${C_LABEL}󰢮 GPU     ${C_RESET} $gpu"
echo -e "  ${C_LABEL} MEMORY  ${C_RESET} $memory"
