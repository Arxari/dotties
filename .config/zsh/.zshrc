#                     █████     
#                    ░░███      
#   █████████  █████  ░███████  
#  ░█░░░░███  ███░░   ░███░░███ 
#  ░   ███░  ░░█████  ░███ ░███ 
#    ███░   █ ░░░░███ ░███ ░███ 
#   █████████ ██████  ████ █████
#  ░░░░░░░░░ ░░░░░░  ░░░░ ░░░░░ 
# The following lines were added by compinstall

source /home/arx/.config/zsh/.exports

# Zsh Completion Settings
zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle :compinstall filename '/home/arx/.config/zsh/.zshrc'

autoload -Uz compinit
compinit

compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

# Configuration Options
HISTSIZE=1000
SAVEHIST=1000
setopt autocd beep extendedglob
bindkey -e

# Load external tools and initialize environment
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
source /home/arx/.antidote/antidote.zsh
antidote load
eval "$(starship init zsh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
eval "$(rbenv init -)"



# Aliases
alias upd='paru -Syyu --noconfirm && flatpak update -y && determination-update'
alias updshut='refup && paru -Syyu --noconfirm && flatpak update -y && shutdown'
alias refup='sudo reflector --verbose --country CZ,DE --protocol https --sort rate --latest 20 --download-timeout 300 --save /etc/pacman.d/mirrorlist'
alias cc='paru -Scc'
alias chezdit='chezmoi edit'
alias funistall='flatpak uninstall --delete-data'
alias snap='sudo timeshift --create'
alias goodbye='shutdown'
alias ff='fastfetch'
alias plz='sudo'
alias lemmeout='hyprctl dispatch exit'
alias android='scrcpy --otg -s R7AX101RFRJ' # Mouse and keyboard control on Phone
# Script Aliases
alias shockclock='python3 /home/arx/Playspace/Code/Python/shockclock/clock.py'
alias play='python3 /home/arx/Playspace/Code/OpenShock/immersive-asmr/player.py'
# Micro Aliases
alias zshrc='micro ~/.config/zsh/.zshrc'
alias hyprconf='micro ~/.config/hypr/hyprland.conf'
alias zenconf='micro ~/.zen/5e8upekq.Arxari/chrome/userChrome.css'
alias ffconf='micro ~/.config/fastfetch/config.jsonc'
alias cavaconf='micro ~/.config/cava/config'
alias starconf='micro ~/.config/starship.toml'
alias ignispy='micro /home/arx/.config/ignis/config.py'
alias igniscss='/home/arx/.config/ignis/style.scss'
alias discordtheme='micro /home/arx/.var/app/dev.vencord.Vesktop/config/vesktop/themes/midnight.theme.css'
# cd aliases
alias cdcode='cd ~/Playspace/Code'
alias cdsh='cd ~/Playspace/Code/sh'
alias cdrust='cd ~/Playspace/Code/Rust'
# Cat Aliases
alias shadboi='cat ~/Pictures/cat-art/shadboi.txt'
alias shrekd='cat ~/Pictures/cat-art/shrekd.txt'
# App Launch Aliases
alias flapakfloorp='flatpak run one.ablaze.floorp'
alias discord='flatpak run dev.vencord.Vesktop'
alias obsidian='flatpak run md.obsidian.Obsidian'
alias penpot='flatpak run com.sudovanilla.penpot-desktop'
# AAATBSGSHU
alias backuptar="/home/arx/Playspace/Code/sh/backuptar.sh/backuptar.sh"
alias calc="/home/arx/Playspace/Code/sh/calc.sh/calc.sh"
alias ezcd="/home/arx/Playspace/Code/sh/ezcd/ezcd.sh"
alias ezclone="/home/arx/Playspace/Code/sh/ezclone/ezclone.sh"
alias flights="/home/arx/Playspace/Code/sh/flights.sh"
alias startup="/home/arx/Playspace/Code/sh/startup.sh/startup.sh"
alias lzfi="/home/arx/Playspace/Code/sh/lzfi.sh/lzfi.sh"
alias determination-update="/home/arx/Playspace/Code/sh/determination.sh/determination-update.sh"
alias desktopfinder="/home/arx/Playspace/Code/sh/desktopfinder.sh/desktopfinder.sh"
alias vaporeon="/home/arx/Playspace/Code/sh/vaporeon.sh"
alias shofi="/home/arx/Playspace/Code/sh/Shofi/shofi.sh"
alias launchbashbar="/home/arx/Playspace/Code/sh/Bashbar/launchbashbar.sh"
alias bashbar="/home/arx/Playspace/Code/sh/Bashbar/bashbar.sh"
alias volumectl="/home/arx/Playspace/Code/sh/volumectl.sh"
alias wisdom="/home/arx/Playspace/Code/sh/wisdom.sh"
alias howtogit="/home/arx/Playspace/Code/sh/howtogit.sh/howtogit.sh"
alias rancat="/home/arx/Playspace/Code/sh/rancat.sh/rancat.sh"
alias ddclock="/home/arx/Playspace/Code/sh/ddclock.sh/ddclock.sh"
alias ezsh='~/Playspace/Code/sh/ezsh/ezsh.sh'
alias lzps='~/Playspace/Code/sh/lzps.sh/lzps.sh'

# PS; If you're reading this you're a cutie patootie

#!/bin/bash

command_not_found_handler() {
    local api_key="cfVNzGzgTSugwbJwGFgUVSoAuRT77bTnuG2vxbIhMYqyY8Zi2yZNqVOaA15EWUiN"  # Replace with your API key
    local shock_id="c75ad4c6-5d18-4a55-b4a2-797184caedd5"  # Replace with your shocker ID
    local intensity=50  # Set the intensity (0-100)
    local duration=1000  # Set the duration in milliseconds
    local shock_type="Shock" # Can also vibrate or beep

    echo "Command '$1' not found. Sending shock..."

    response=$(curl -s -w "%{http_code}" -o /dev/null -X POST \
        "https://api.shocklink.net/2/shockers/control" \
        -H "accept: application/json" \
        -H "OpenShockToken: $api_key" \
        -H "Content-Type: application/json" \
        -d '{
            "shocks": [{
                "id": "'"$shock_id"'",
                "type": "'"$shock_type"'",
                "intensity": '"$intensity"',
                "duration": '"$duration"',
                "exclusive": true
            }],
            "customName": "Linux terminal shock-aided learning tool"
        }')

    if [ "$response" -eq 200 ]; then
        echo "$shock_type sent successfully." # You can change this to something funny or cool if you wanna
    else
        echo "Failed to send $shock_type. Response code: $response"
    fi
}


