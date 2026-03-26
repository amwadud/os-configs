#!/usr/bin/env sh

swayidle -w \
    timeout 300 swaylock \
    timeout 600 'swaymsg "output * dpms off"' \
    resume 'swaymsg "output * dpms on"'
