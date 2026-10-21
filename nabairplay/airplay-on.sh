#!/usr/bin/env bash
exec /bin/bash "$(dirname "$(readlink -f "$0")")/airplay-hook.sh" on
