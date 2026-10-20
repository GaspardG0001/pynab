# Pynab AirPlay (v1, AirPlay 1)

Receives AirPlay 1 audio on the Nabaztag using [Shairport Sync](https://github.com/mikebrady/shairport-sync).

## How it works
- Shairport Sync advertises a receiver named `Nabaztag` and plays on the Tag:Tag ALSA card.
- At session start/end, Shairport runs `airplay-on.sh` / `airplay-off.sh`, which send `{"type":"airplay","state":"on|off"}` to `nabd` (localhost:10543).
- On `on`, `nabd` stops the current sound and refuses new playback/recording until `off`. Interrupted sounds are not replayed; there is no mixing. LEDs, ears and services keep working.
- If Shairport crashes, systemd's `ExecStopPost` sends `off`. A `nabd` restart always starts with sound enabled.
- If Shairport is absent or disabled, Pynab behaves exactly as before.

## Install / uninstall
```
sudo bash nabairplay/install-airplay.sh
sudo bash nabairplay/uninstall-airplay.sh [--purge]
```
Rename the receiver by editing `name` in `/etc/shairport-sync.conf`, then `sudo systemctl restart shairport-sync`.
Disable AirPlay only: `sudo systemctl disable --now shairport-sync`.
Pynab upgrades (`upgrade.sh`) do not touch these files.

Images built by GitHub Actions (`setup` script, `ci-chroot`) include AirPlay: `install-airplay.sh --chroot` installs Shairport Sync, assumes the Tag:Tag card (`AIRPLAY_CARD` to override) and enables the service for first boot. A failure there does not fail the image build.

## Diagnostics
```
journalctl -u shairport-sync -f
journalctl -t nabairplay -f
journalctl -u nabd -f
```

## Limitations
- Requires a Shairport Sync build compatible with ARMv6/Raspbian Buster (Buster's package is 3.2.x, AirPlay 1) — to be verified on hardware.
- While AirPlay plays, Pynab sounds and voice recognition recording are dropped.
- No nabweb UI, metadata, LED/ear animation.

## Hardware validation (T01–T12)
Results to be filled in after tests on the target device.
