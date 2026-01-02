#!/bin/sh
set -eu

# Touchpad settings (X11 + libinput)
# - Applies only to real touchpads
# - Safe for systems where a touchpad exposes multiple logical devices (I2C + PS/2)
# - Does NOT affect mouse / trackpoint devices

# =========================
# Tunables
# =========================

# Pointer speed and acceleration
TP_ACCEL_SPEED="-0.2"          # [-1.0, 1.0], negative = slower, more precise
PROFILE="adaptive"             # adaptive | flat

# Scrolling
TP_NATURAL_SCROLL="1"          # 1 = natural scrolling
TP_SCROLL_PIXEL_DISTANCE="50"  # larger = slower scrolling (critical for XI2)

# Tapping
TP_TAPPING="1"                 # 1 = tap-to-click
TP_TAP_DRAG="1"                # tap + drag
TP_TAP_MAPPING="1 0"           # lrm: 1-finger left, 2-finger right, 3-finger middle

# =========================
# Helpers
# =========================

has_prop() {
  id="$1"
  prop="$2"
  xinput list-props "$id" 2>/dev/null | grep -Fq "$prop"
}

apply_touchpad() {
  id="$1"

  # A real touchpad always exposes Tapping
  if ! has_prop "$id" "libinput Tapping Enabled"; then
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
  if has_prop "$id" "libinput Accel Speed"; then
    xinput set-prop "$id" "libinput Accel Speed" "$TP_ACCEL_SPEED"
  fi

  # Natural scrolling
  if has_prop "$id" "libinput Natural Scrolling Enabled"; then
    xinput set-prop "$id" "libinput Natural Scrolling Enabled" "$TP_NATURAL_SCROLL"
  fi

  # Scrolling speed (XI2 path)
  if has_prop "$id" "libinput Scrolling Pixel Distance"; then
    xinput set-prop "$id" "libinput Scrolling Pixel Distance" "$TP_SCROLL_PIXEL_DISTANCE"
  fi

  # Tapping
  xinput set-prop "$id" "libinput Tapping Enabled" "$TP_TAPPING"
  xinput set-prop "$id" "libinput Tapping Drag Enabled" "$TP_TAP_DRAG"
  xinput set-prop "$id" "libinput Tapping Button Mapping Enabled" $TP_TAP_MAPPING
}

# =========================
# Enumerate & apply
# =========================

xinput list --short \
  | sed -n 's/.*id=\([0-9]\+\).*/\1/p' \
  | while read -r id; do
      apply_touchpad "$id"
    done

exit 0

