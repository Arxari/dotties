#!/bin/bash
IGNIS_CONFIG_DIR="$HOME/.config/ignis"
STYLES_DIR="$IGNIS_CONFIG_DIR/styles"

if [ $# -eq 0 ]; then
    echo "Usage: $0 <profile_name>"
    echo "Available profiles:"
    ls "$STYLES_DIR"
    exit 1
fi

PROFILE="$1"
PROFILE_DIR="$STYLES_DIR/$PROFILE"

if [ ! -d "$PROFILE_DIR" ]; then
    echo "Profile '$PROFILE' not found."
    echo "Available profiles:"
    ls "$STYLES_DIR"
    exit 1
fi

ln -sf "$PROFILE_DIR/config.py" "$IGNIS_CONFIG_DIR/config.py"
ln -sf "$PROFILE_DIR/style.scss" "$IGNIS_CONFIG_DIR/style.scss"

pkill ignis

setsid ignis init </dev/null >/dev/null 2>&1 &

echo "Switched to $PROFILE configuration"
