#!/bin/sh
if ! pidof hyprlock > /dev/null 2>&1; then
    hyprlock
    sleep 0.5
    hyprctl keyword monitor eDP-1,2560x1600@60,0x0,2
fi
