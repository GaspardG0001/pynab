#!/usr/bin/env bash
exec "$(dirname "$(readlink -f "$0")")/airplay-hook.sh" on
