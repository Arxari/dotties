#     ██████   ███          █████     
#    ███░░███ ░░░          ░░███      
#   ░███ ░░░  ████   █████  ░███████  
#  ███████   ░░███  ███░░   ░███░░███ 
# ░░░███░     ░███ ░░█████  ░███ ░███ 
#   ░███      ░███  ░░░░███ ░███ ░███ 
#   █████     █████ ██████  ████ █████
#  ░░░░░     ░░░░░ ░░░░░░  ░░░░ ░░░░░ 
set start_time (date +%s.%N)

# source things
source ~/.config/fish/functions/prompt.fish
source /home/arx/.config/fish/.exports
# source /home/arx/.config/fish/functions/shocks.fish

eval "$(zoxide init fish)"

# defaults
export EDITOR=nvim

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
alias fftrans='hyfetch -p transgender'
alias ffbi='hyfetch -p bisexual'
alias plz='sudo'
alias lemmeout='hyprctl dispatch exit'
alias android='scrcpy --otg -s R7AX101RFRJ' # Mouse and keyboard control on Phone

# Script Aliases
alias shockclock='python3 /home/arx/Playspace/Code/Python/shockclock/clock.py'
alias play='python3 /home/arx/Playspace/Code/OpenShock/immersive-asmr/player.py'

# Editor aliases
alias fishrc='$EDITOR ~/.config/fish/config.fish'
alias promptconf='$EDITOR ~/.config/fish/functions/prompt.fish'
alias alacrittyconf='$EDITOR ~/.config/alacritty/alacritty.toml'
alias hyprconf='$EDITOR ~/.config/hypr/hyprland.conf'
alias nvimconf='$EDITOR ~/.config/nvim/init.lua'
##############################################
alias zenconf='$EDITOR ~/.zen/5e8upekq.Arxari/chrome/userChrome.css'
alias ffconf='$EDITOR ~/.config/fastfetch/config.jsonc'
alias cavaconf='$EDITOR ~/.config/cava/config'
alias starconf='$EDITOR ~/.config/starship.toml'
alias ignispy='$EDITOR /home/arx/.config/ignis/config.py'
alias igniscss='$EDITOR /home/arx/.config/ignis/style.scss'
alias discordtheme='$EDITOR /home/arx/.var/app/dev.vencord.Vesktop/config/vesktop/themes/midnight.theme.css'

# cd aliases
alias cdcode='cd ~/Playspace/Code'
alias cdsh='cd ~/Playspace/Code/sh'
alias cdrust='cd ~/Playspace/Code/Rust'

# Cat Aliases
alias shrekd='cat ~/Pictures/cat-art/shrekd.txt'

# App Launch Aliases
alias penpot='flatpak run com.sudovanilla.penpot-desktop & disown'

# AAATBSGSHU
alias bttrqemu="/home/arx/Playspace/Code/sh/bttrqemu/bttrqemu.sh"
alias backuptar="/home/arx/Playspace/Code/sh/backuptar.sh/backuptar.sh"
alias calc="/home/arx/Playspace/Code/sh/calc.sh/calc.sh"
alias ezcd="/home/arx/Playspace/Code/sh/ezcd/ezcd.sh"
alias ezclone="/home/arx/Playspace/Code/sh/ezclone/ezclone.sh"
alias repoman='~/Playspace/Code/sh/repoman/repoman.sh'
alias lzfi="/home/arx/Playspace/Code/sh/lzfi.sh/lzfi.sh"
alias determination-update="/home/arx/Playspace/Code/sh/determination.sh/determination-update.sh"
alias desktopfinder="/home/arx/Playspace/Code/sh/desktopfinder.sh/desktopfinder.sh"
alias shofi="/home/arx/Playspace/Code/sh/Shofi/shofi.sh"
alias volumectl="/home/arx/Playspace/Code/sh/volumectl.sh"
alias wisdom="/home/arx/Playspace/Code/sh/wisdom.sh"
alias howtogit="/home/arx/Playspace/Code/sh/howtogit.sh/howtogit.sh"
alias rancat="/home/arx/Playspace/Code/sh/rancat.sh/rancat.sh"
alias ddclock="/home/arx/Playspace/Code/sh/ddclock.sh/ddclock.sh"
alias ezsh='~/Playspace/Code/sh/ezsh/ezsh.sh'
alias lzps='~/Playspace/Code/sh/lzps.sh/lzps.sh'
alias fpk='~/Playspace/Code/sh/fpk/fpk.sh'

# PS; If you're reading this you're a cutie patootie

# starship init fish | source

set end_time (date +%s.%N)
set elapsed (math "$end_time - $start_time")
set formatted_elapsed (printf "%.3f seconds" $elapsed)

set -U fish_greeting "Launched in $formatted_elapsed"
