#!/bin/sh
set -eu

# Mouse/trackpoint settings (X11 + libinput)
# - Applies to devices whose name contains "mouse" or "trackpoint"
# - Skips any device that looks like a touchpad (has "Tapping Enabled" property)
# - Safe for setups where a touchpad exposes an additional "... Mouse" node

# Tunables
MOUSE_ACCEL_SPEED="0.0"     # [-1.0, 1.0], 0.0 is default; try 0.2 if you want faster
PROFILE="flat"          # adaptive | flat
# Natural scrolling for mouse is usually OFF; set to 1 if you really want it
MOUSE_NATURAL_SCROLL="0"    # 0/1

# Helper: check if a property exists for an id
has_prop() {
  id="$1"
  prop="$2"
  xinput list-props "$id" 2>/dev/null | grep -Fq "$prop"
}

# Apply per-device settings
apply_mouse() {
  id="$1"

  # Skip touchpads: they typically expose "libinput Tapping Enabled"
  if has_prop "$id" "libinput Tapping Enabled"; then
    return 0
  fi

  # Only touch devices driven by libinput
  if ! has_prop "$id" "libinput Accel Speed"; then
    return 0
  fi

  # Accel profile
  if has_prop "$id" "libinput Accel Profile Enabled"; then
    case "$PROFILE" in
      adaptive) xinput set-prop "$id" "libinput Accel Profile Enabled" 1 0 ;;
      flat)     xinput set-prop "$id" "libinput Accel Profile Enabled" 0 1 ;;
    esac
  fi

  # Pointer speed
  xinput set-prop "$id" "libinput Accel Speed" "$MOUSE_ACCEL_SPEED"

  # Natural scrolling (optional)
  if has_prop "$id" "libinput Natural Scrolling Enabled"; then
    xinput set-prop "$id" "libinput Natural Scrolling Enabled" "$MOUSE_NATURAL_SCROLL"
  fi
}

# Enumerate candidate device IDs.
# We intentionally search for "mouse" and "trackpoint" and avoid matching touchpads.
xinput list --short \
  | grep -Ei 'mouse|trackpoint' \
  | sed -n 's/.*id=\([0-9]\+\).*/\1/p' \
  | while read -r id; do
      apply_mouse "$id"
    done

exit 0

