#!/bin/bash
# Script for Monitor backlights using brightnessctl
# Explicitly targets acpi_video0 to avoid controlling the Touch Bar
# Features: Snap-to-grid rounding (fixes the 1% -> 11% issue)

iDIR="$HOME/.config/swaync/icons"
notification_timeout=1000
step=10

# Force the script to use the screen backlight
DEVICE="acpi_video0"

# Get current brightness as an integer (without %)
get_brightness() {
  brightnessctl --device="$DEVICE" -m | cut -d, -f4 | tr -d '%'
}

# Determine the icon based on brightness level
get_icon_path() {
  local brightness=$1
  local level=$(((brightness + 19) / 20 * 20))
  if ((level > 100)); then
    level=100
  fi
  echo "$iDIR/brightness-${level}.png"
}

# Send notification
send_notification() {
  local brightness=$1
  local icon_path=$2

  notify-send -e \
    -h string:x-canonical-private-synchronous:brightness_notif \
    -h int:value:"$brightness" \
    -u low \
    -i "$icon_path" \
    "Screen" "Brightness: ${brightness}%"
}

# Change brightness with rounding logic
change_brightness() {
  local direction=$1
  local current new icon

  current=$(get_brightness)

  if [ "$direction" == "inc" ]; then
    # Math: Round UP to the nearest multiple of step (1 -> 10, 11 -> 20)
    new=$((((current / step) + 1) * step))
  elif [ "$direction" == "dec" ]; then
    # Math: Round DOWN to the nearest multiple of step (11 -> 10, 10 -> 0)
    new=$((((current - 1) / step) * step))
  fi

  # Safety Clamping
  # Prevent going above 100
  if [ "$new" -gt 100 ]; then new=100; fi

  # Prevent going below 1 (Keep screen barely on instead of black)
  if [ "$new" -lt 1 ]; then new=1; fi

  # Set brightness explicitly on the screen
  brightnessctl --device="$DEVICE" set "${new}%"

  icon=$(get_icon_path "$new")
  send_notification "$new" "$icon"
}

# Main
case "$1" in
"--get")
  get_brightness
  ;;
"--inc")
  change_brightness "inc"
  ;;
"--dec")
  change_brightness "dec"
  ;;
*)
  get_brightness
  ;;
esac

