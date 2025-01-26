#!/bin/bash
IGNIS_CONFIG_DIR="$HOME/.config/ignis"
STYLES_DIR="$IGNIS_CONFIG_DIR/styles"
WALLPAPERS_DIR="$HOME/Pictures/Wallpapers"

show_usage() {
    echo "Usage: $0 [-w] <profile_name>"
    echo "Available profiles:"
    ls "$STYLES_DIR"
    exit 1
}

USE_WALLPAPER=false
PROFILE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -w)
            USE_WALLPAPER=true
            shift
            ;;
        *)
            if [[ -z "$PROFILE" ]]; then
                PROFILE="$1"
            else
                show_usage
            fi
            shift
            ;;
    esac
done

if [ -z "$PROFILE" ]; then
    show_usage
fi

PROFILE_DIR="$STYLES_DIR/$PROFILE"
if [ ! -d "$PROFILE_DIR" ]; then
    echo "Profile '$PROFILE' not found."
    echo "Available profiles:"
    ls "$STYLES_DIR"
    exit 1
fi

ln -sf "$PROFILE_DIR/config.py" "$IGNIS_CONFIG_DIR/config.py"
ln -sf "$PROFILE_DIR/style.scss" "$IGNIS_CONFIG_DIR/style.scss"

if [ "$USE_WALLPAPER" = true ]; then
    WALLPAPER=$(find "$WALLPAPERS_DIR" -type f \( -iname "*$PROFILE*.png" -o -iname "*$PROFILE*.jpg" -o -iname "*$PROFILE*.jpeg" \) -print -quit)

    if [ -z "$WALLPAPER" ]; then
        echo "No wallpaper found matching '$PROFILE'"
        exit 1
    fi

    swww img "$WALLPAPER"
fi

pkill ignis

setsid ignis init </dev/null >/dev/null 2>&1 &

echo "Switched to $PROFILE configuration"
if [ "$USE_WALLPAPER" = true ]; then
    echo "Applied wallpaper: $WALLPAPER"
fi
