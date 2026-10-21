#!/usr/bin/env bash
# Disable AirPlay and restore previous configuration. Pynab is left untouched.
# Usage: sudo bash nabairplay/uninstall-airplay.sh [--purge]  (--purge also removes the package)
set -uo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root (sudo)." >&2
  exit 1
fi

root_dir="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
conf=/etc/shairport-sync.conf

systemctl stop shairport-sync 2>/dev/null || true
systemctl disable shairport-sync 2>/dev/null || true
rm -f /etc/systemd/system/shairport-sync.service.d/pynab.conf
rmdir /etc/systemd/system/shairport-sync.service.d 2>/dev/null || true
if [ -f "${conf}.pynab-backup" ]; then
  mv "${conf}.pynab-backup" "${conf}"
fi
systemctl daemon-reload

# Make sure nabd has its sound back.
"${root_dir}/nabairplay/airplay-off.sh" || true

if [ "${1:-}" = "--purge" ]; then
  apt-get remove -y shairport-sync
fi
echo "AirPlay disabled."
