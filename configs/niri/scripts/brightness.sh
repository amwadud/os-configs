#!/usr/bin/env bash

ACTION=$1                                                     # "vol_up" "vol_down" "mute" "mic_mute"
ICON_VOL="$HOME/.config/niri/scripts/assets/icons/volume.png" # Volume icon
ICON_MIC="$HOME/.config/niri/scripts/assets/icons/mic.png"    # Mic icon
SAFE_MAX=0.65                                                 # 65% safe max volume

# Function to update volume
volume_notify() {
    # Get current volume and mute
    read -r VOL_RAW <<<"$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')"
    read -r MUTE_RAW <<<"$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo yes || echo no)"
    VOL=$VOL_RAW
    MUTE=$MUTE_RAW

    case "$1" in
    "up")
        if (($(echo "$VOL < $SAFE_MAX" | bc -l))); then
            wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01+
            VOL=$(echo "$VOL + 0.01" | bc)
        fi
        ;;
    "down")
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01-
        VOL=$(echo "$VOL - 0.01" | bc)
        ;;
    "toggle")
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        MUTE=$([[ "$MUTE" == "yes" ]] && echo no || echo yes)
        ;;
    esac

    # Clamp for progress bar
    PROG=$(awk -v v="$VOL" 'BEGIN{v*=100; if(v>100)v=100; print int(v)}')

    # Send notification
    if [[ "$MUTE" == "yes" ]]; then
        notify-send -t 400 -i "$ICON_VOL" -h string:x-canonical-private-synchronous:volume "Muted"
    else
        notify-send -t 400 -i "$ICON_VOL" -h string:x-canonical-private-synchronous:volume -h int:value:$PROG "Volume $PROG%"
    fi
}

# Function to toggle mic mute
mic_notify() {
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
    MUTE=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED && echo yes || echo no)
    notify-send -t 400 -i "$ICON_MIC" \
        "Mic $([[ "$MUTE" == "yes" ]] && echo "Muted" || echo "Unmuted")"
}

# Main dispatcher
case "$ACTION" in
"vol_up") volume_notify "up" ;;
"vol_down") volume_notify "down" ;;
"mute") volume_notify "toggle" ;;
"mic_mute") mic_notify ;;
esac
