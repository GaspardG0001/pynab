#!/usr/bin/env bash
# Tell nabd that an AirPlay session started ("on") or ended ("off").
# Called by Shairport Sync hooks and by systemd (ExecStopPost).
# Never fails: a nabd problem must not prevent AirPlay from working.
state="${1:-}"
host="${NABD_HOST:-127.0.0.1}"
port="${NABD_PORT:-10543}"

case "${state}" in
  on|off) ;;
  *) logger -t nabairplay "usage: $0 on|off"; exit 0 ;;
esac

# nabd sends a state packet on connect, then the response to our packet.
# Waiting for the response guarantees nabd released the sound device.
timeout 5 bash -c '
  exec 3<>"/dev/tcp/$1/$2" || exit 1
  printf "{\"type\":\"airplay\",\"state\":\"%s\"}\r\n" "$3" >&3
  read -r -t 4 -u 3 _ && read -r -t 4 -u 3 _
' _ "${host}" "${port}" "${state}"
rc=$?
if [ ${rc} -ne 0 ]; then
  logger -t nabairplay "could not notify nabd (state=${state}, rc=${rc})"
else
  logger -t nabairplay "nabd notified: airplay ${state}"
fi
exit 0
