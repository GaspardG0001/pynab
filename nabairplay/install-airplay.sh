#!/usr/bin/env bash
# Install AirPlay 1 reception (Shairport Sync) on an existing Pynab.
# Usage: sudo bash nabairplay/install-airplay.sh
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root (sudo)." >&2
  exit 1
fi

root_dir="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
conf=/etc/shairport-sync.conf
dropin_dir=/etc/systemd/system/shairport-sync.service.d

echo "Checking environment"
if ! systemctl cat nabd.service >/dev/null 2>&1; then
  echo "Pynab (nabd.service) is not installed." >&2
  exit 1
fi
card=""
for name in tagtagtagsound sndrpihifiberry; do
  if grep -q "\[${name}" /proc/asound/cards; then card="${name}"; fi
done
if [ -z "${card}" ]; then
  echo "No supported sound card found in /proc/asound/cards." >&2
  exit 1
fi
echo "Sound card: ${card}"

echo "Installing Shairport Sync"
if ! command -v shairport-sync >/dev/null 2>&1; then
  apt-get update
  apt-get install -y shairport-sync
fi
if shairport-sync -V | grep -qi airplay2; then
  echo "Warning: AirPlay 2 build detected; v1 targets AirPlay 1 builds." >&2
fi

echo "Configuring"
if [ -f "${conf}" ] && [ ! -f "${conf}.pynab-backup" ]; then
  cp "${conf}" "${conf}.pynab-backup"
fi
sed -e "s|@ALSA_DEVICE@|plughw:CARD=${card}|" -e "s|@ROOT_DIR@|${root_dir}|g" \
  "${root_dir}/nabairplay/shairport-sync.conf.in" > "${conf}"
mkdir -p "${dropin_dir}"
sed -e "s|@ROOT_DIR@|${root_dir}|g" \
  "${root_dir}/nabairplay/shairport-sync-pynab.conf" > "${dropin_dir}/pynab.conf"
chmod +x "${root_dir}"/nabairplay/*.sh

echo "Enabling services"
systemctl daemon-reload
systemctl enable shairport-sync
systemctl restart shairport-sync
sleep 3
if systemctl is-active --quiet shairport-sync; then
  echo "AirPlay receiver 'Nabaztag' is running."
  echo "Diagnostics: journalctl -u shairport-sync -t nabairplay -f"
else
  echo "shairport-sync failed to start (Pynab is unaffected):" >&2
  journalctl -u shairport-sync -n 20 --no-pager >&2 || true
  exit 1
fi
