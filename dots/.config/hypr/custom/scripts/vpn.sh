#!/usr/bin/env bash
# Work VPN toggle for the ii bar (VpnToggle.qml).
#   vpn.sh status  -> prints "<state> <tun address>", state is active|activating|inactive
#   vpn.sh toggle  -> stops the VPN, or gets a TOTP and connects through vpn-connect
# Connecting relies on a sudoers rule for /usr/local/bin/vpn-connect (it reads the TOTP on stdin).
#
# TOTP: taken from Ente Auth through the `totp` script next to this one (entries synced into the
# keyring); VPN_TOTP picks the entry by name. Without a match it asks with a fuzzel prompt.
UNIT="${VPN_UNIT:-openvpn-client@virtua.service}"
DEV="${VPN_DEV:-tun0}"
VPN_TOTP="${VPN_TOTP:-OpenVPN}"
state="$(systemctl is-active "$UNIT")"

generated_otp() {
  # TOTP_MIN_LEFT: a code about to roll over may expire before the server checks it; wait for the next one
  TOTP_MIN_LEFT=4 "$(dirname "$(readlink -f "$0")")/totp" code "$VPN_TOTP" 2>/dev/null
}

case "$1" in
toggle)
  if [ "$state" = active ] || [ "$state" = activating ]; then
    systemctl stop "$UNIT"
    exit
  fi
  if ! otp="$(generated_otp)"; then
    otp="$(fuzzel --dmenu --password --prompt-only '󰦝 TOTP  ' </dev/null)" || exit 0
  fi
  [ -n "$otp" ] || exit 0
  if err="$(printf '%s' "$otp" | sudo -n /usr/local/bin/vpn-connect 2>&1)"; then
    notify-send -a VPN "VPN connected"
  else
    notify-send -a VPN -u critical "VPN failed" "${err:-check: journalctl -u $UNIT}"
  fi
  ;;
*)
  case "$state" in
  active | activating) ;;
  *) state=inactive ;;
  esac
  addr="$(ip -br addr show dev "$DEV" 2>/dev/null | awk '{ print $3 }')"
  echo "$state $addr"
  ;;
esac
