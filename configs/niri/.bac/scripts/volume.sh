#!/usr/bin/env bash

ACTION=$1
ICON="$HOME/.config/niri/scripts/assets/icons/volume.png"
SAFE_MAX=1.0

# Get volume and mute in one call
read -r RAW_VOL <<<"$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')"
read -r MUTE_RAW <<<"$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo yes || echo no)"

VOL=$RAW_VOL
MUTE=$MUTE_RAW

# Adjust volume safely
case "$ACTION" in
"+")
    if (($(echo "$VOL < $SAFE_MAX" | bc -l))); then
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.01+
        VOL=$(echo "$VOL + 0.01" | bc)
    fi
    ;;
"-")
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

# Only send notification if changed
if [[ "$MUTE" == "yes" ]]; then
    notify-send -t 1000 -i "$ICON" -h string:x-canonical-private-synchronous:volume "Muted"
else
    notify-send -t 1000 -i "$ICON" -h string:x-canonical-private-synchronous:volume -h int:value:$PROG "Volume $PROG%"
fi
