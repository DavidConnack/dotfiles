#!/opt/homebrew/bin/bash
date=$(date '+ %a %b %d %I:%M %p')
context=$(kubectl config current-context)
battery_icon="󰂄"
battery=$(pmset -g batt | grep -Eo '\d+%')
[[ $(pmset -g batt | grep -o discharging) ]] && battery_icon="󰁹"
echo "$date|󱃾 :$context|$battery_icon:$battery "
