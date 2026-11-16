# Gotcha: BT headset "connected" but no audio

**Hardware:** MCHOSE V9 PRO (tri-mode: BT / 2.4GHz dongle / USB) — `B5:11:26:00:32:41`
**Stack:** PipeWire + WirePlumber + bluez on NixOS

## TL;DR fix

```sh
systemctl --user stop wireplumber
sed -i '/bluez_card.B5_11_26_00_32_41/d' \
  ~/.local/state/wireplumber/default-profile \
  ~/.local/state/wireplumber/default-routes
systemctl --user start wireplumber
# then: bluetoothctl disconnect <mac> && bluetoothctl connect <mac>
```

## The gotcha: three lifetimes of state

| Layer | Lives in | Survives rebuild? |
|---|---|---|
| config | dotfiles (declarative) | yes |
| runtime | WirePlumber memory | no |
| **persisted state** | `~/.local/state/wireplumber/` | **yes — rebuilds never touch it** |

WirePlumber stores a "last known profile" per BT card in
`default-profile`. After any transport failure it may store `off` — and
then faithfully restore `off` on **every** future connect. The stored
profile *overrides* `bluez5.auto-connect`, so the fallback policy in
`configuration.nix` never gets consulted. Result: headset connects fine
(mic node even appears as a shell), but no `bluez_sink` is ever created.

**Symptom signature:** `wpctl status` shows the device under Devices,
no `bluez_sink` under Sinks, and `wpctl inspect <id>` shows
`bluez5.profile = "off"`. Restarting WP/rebooting changes nothing — the
wedge is on disk.

**If audio weirdness survives a rebuild, stop debugging config and read
`~/.local/state/`.**

## Why each step exists

1. **Stop WP before editing** — it rewrites its state files on exit;
   editing live files races against that.
2. **Delete the stored line** — the card now has no stored profile,
   which is the condition under which `bluez5.auto-connect`
   (`a2dp_sink` first) finally runs. Safe: the whole dir is
   regenerable cache.
3. **Reconnect** — profile selection is triggered by a *new connection
   event*, not retroactively. On connect: no stored profile →
   auto-connect → a2dp transport → sink node appears → apps re-target
   automatically.

Restarting WP alone (without scrubbing) is useless: fresh process, same
disk, same `off`.

## Diagnosis path (in order)

```sh
wpctl status          # no bluez_sink under Sinks? → transport/profile layer
wpctl inspect <id>    # bluez5.profile = "off"? → profile never activated
journalctl --user -u wireplumber -b --no-pager   # usually silent; don't trust absence
journalctl -u bluetooth -b --no-pager            # HFP/AVCTP negotiation lives here
sudo btmon            # raw HCI/AVDTP trace while (re)connecting
grep bluez_card ~/.local/state/wireplumber/default-profile
```

Notes on reading these:

- `bluetoothd` log: `Endpoint registered: .../A2DPSink/...` means our
  A2DP endpoints are fine. `Unable to get Hands-Free Voice gateway SDP
  record` / `ext_connect ... Connection refused` = headset-side HFP
  flakiness. `Refusing unexpected connect` (AVCTP) = headset knocking
  on a control channel with no media transport behind it.
- `btmon`: healthy A2DP is Discover → Get Capabilities → Set
  Configuration → Open. Watch who *initiates* — see quirks below.

## Quirks of this headset (observed 2025-11-16)

- Firmware is janky: HFP voice-gateway SDP lookups fail intermittently,
  AT commands error out (`+CME ERROR: 1`), and after a power cycle it
  initiated AVDTP *itself* with inverted roles (behaving like a phone
  streaming into the PC), negotiating plain SBC even though AAC is
  first in our codec whitelist.
- A wedge can re-form whenever a transport dies (WP saves the resulting
  profile). If it recurs, repeat the TL;DR — it's a two-liner.
- One more mode-related trap: the headset's USB/dongle mode enumerates
  as a separate ALSA card (`alsa_output.usb-C-Media...MCHOSE_V9_PRO`).
  Saved default routes for that form factor do **not** apply to the BT
  card — they're different PipeWire objects.

## Related cleanup

`hardware.bluetooth.settings General.Enable` (configuration.nix) is
dead — bluetoothd 5.86 logs `Unknown key Enable for group General` and
ignores it (Source/Sink/Media are always enabled in modern bluez).
