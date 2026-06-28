#!/bin/sh
# Noctalia v5 — remember a wallpaper per theme mode (dark/light).
#
# Manual mode switching, no fixed paths: whatever wallpaper you set while in a
# given mode is remembered, and restored automatically when you return to it.
#
# Runs on BOTH hooks: wallpaper_changed and theme_mode_changed.
#   - You switch mode   -> restores the wallpaper you last used in that mode
#   - You pick a paper  -> remembers it for the current mode
#
# State is kept in ~/.config/noctalia/state/:
#   wallpaper-dark, wallpaper-light  (remembered path per mode)
#   last-mode                        (used to detect mode switches)
#
# Repo: https://github.com/farhadeidi/noctalia-dark-light-wallpaper
set -eu

state="$HOME/.config/noctalia/state"
mkdir -p "$state"

mode=$(noctalia msg theme-mode-get)              # -> dark | light
last=$(cat "$state/last-mode" 2>/dev/null || true)
wp=$(noctalia msg wallpaper-get)                 # -> current default wallpaper path
slot="$state/wallpaper-$mode"

if [ "$mode" != "$last" ]; then
    # ---- theme mode switched: restore this mode's saved wallpaper ----
    printf '%s\n' "$mode" > "$state/last-mode"
    saved=$(cat "$slot" 2>/dev/null || true)
    if [ -n "$saved" ] && [ -f "$saved" ]; then
        [ "$saved" != "$wp" ] && noctalia msg wallpaper-set "$saved"
    else
        # nothing remembered for this mode yet -> seed with current wallpaper
        [ -n "$wp" ] && printf '%s\n' "$wp" > "$slot"
    fi
else
    # ---- same mode: user changed wallpaper, so remember it ----
    [ -n "$wp" ] && printf '%s\n' "$wp" > "$slot"
fi
