---
name: aone2-slice-deploy
description: Slice a PetFeeder part STL with the AONE2 print profile and drop the gcode into the Klipper Raspberry Pi's print folder. Use when the user wants to slice a part (housing, end_cap, wheel, funnel, …) and send it to the AONE2/AONE21 printer ("наслайси і поклади gcode на малинку / на принтер"). Covers the NUC→Mac→Pi SSH chain, the OrcaSlicer-CLI config-swap trick, and the upload.
---

# Slice a part on the AONE2 profile → deploy to the Klipper Pi

End-to-end: take a part's STL (from this repo), slice it with the exact
profile the user keeps in `petFeeder.3mf` on the Mac, and drop the gcode
into the printer's project folder on the Pi.

## The machines (this print farm)
- **NUC** (here): OpenSCAD source + STLs live in `hardware/`.
- **macmini** — ssh alias `macmini` (192.168.88.43, user `rossano`, key
  `~/.ssh/id_rsa`). Has **OrcaSlicer 2.3.2** + `~/Downloads/petFeeder.3mf`
  (the profile source) + `~/Downloads/klipper_estimator_osx`. **Slicing
  happens here.**
- **Pi `raspb5`** (192.168.88.102, user `rossano`) — Klipper via kiauh,
  two instances **AONE21 / AONE22**. Target printer = **AONE21**; gcode
  dir `~/AONE21_data/gcodes/`, project folder
  `~/AONE21_data/gcodes/petFeeder/`. (NOT the default printer_data/gcodes.)

## Connecting to the Pi — the tricky bit
The Mac→Pi key is in the macOS **Keychain** (passphrase-protected), so a
non-interactive `ssh rossano@192.168.88.102` from our session fails with
`Permission denied (publickey)`. Use the **running GUI ssh-agent** (launchd
socket), which already has the key loaded:
```
SOCK=$(ls /private/tmp/com.apple.launchd.*/Listeners 2>/dev/null | head -1)
SSH_AUTH_SOCK="$SOCK" ssh -o BatchMode=yes rossano@192.168.88.102 '…' < /dev/null
```
Every Mac→Pi `ssh`/`scp` must export `SSH_AUTH_SOCK="$SOCK"`. No headless
fallback if rossano isn't logged into the Mac GUI (passphrase only in the
keychain). We reach the Pi as: NUC →(key)→ macmini →(GUI agent)→ Pi.

## Slicing (OrcaSlicer 2.3.2 CLI on the Mac)
`--load-settings` does NOT accept user presets (they inherit a system
preset → "unknown config type") nor a 3mf project config ("from project
unsupported"). The reliable trick:
1. `OrcaSlicer --arrange 1 --export-3mf part.3mf part.stl` (default config).
2. Replace `Metadata/project_settings.config` inside `part.3mf` with the
   one from `petFeeder.3mf`, **minus the `post_process` key** — the CLI
   can't run post-process scripts ("postprocess not supported, array size
   2", even with `--no-check`).
3. `OrcaSlicer --no-check --arrange 1 --slice 0 --outputdir OUT part.3mf`
   → `OUT/plate_1.gcode`.

Profile in `petFeeder.3mf`: **AONE2 0.4 nozzle**, process **0.20mm W02222**,
filament **monofilament PLA - dark_gray 1450_70**, gcode_flavor **klipper**,
bed 55 / nozzle 205, 15% infill.

Helper: `pf_make.py` (in this skill dir). Copy it to the Mac and run
`python3 pf_make.py <stl> <name> [<stl2> <name2> …]` — it pulls the config
straight from `~/Downloads/petFeeder.3mf`, slices each, prints the gcode
path. Verify the gcode header has `gcode_flavor = klipper` and
`printer_settings_id = AONE2 0.4 nozzle_`.

Per-run profile tweaks go through `PF_CONFIG_OVERRIDE` (a JSON dict merged
into the config), e.g. inner+outer brim 3 mm:
`PF_CONFIG_OVERRIDE='{"brim_type":"outer_and_inner","brim_width":"3"}' python3 pf_make.py …`
(OrcaSlicer `brim_type`: no_brim | outer_only | inner_only | outer_and_inner | auto_brim.)
**Values are strings** — `"brim_width":5` (int) is ignored and falls back to
0 (= no actual brim); use `"brim_width":"3"`.

## After slicing
- Refine estimates (talks to Moonraker):
  `~/Downloads/klipper_estimator_osx --config_moonraker_url http://192.168.88.102:81 post-process <gcode>`
- **Skip** `~/Downloads/gcode_post_process.py` — it pops a macOS modal
  dialog (osascript), not headless-friendly. (That script is what adds the
  `…UAH` cost to the user's normal filenames; ours won't have it.)
- **Thumbnail / Mainsail preview.** The headless OrcaSlicer CLI does NOT
  render gcode thumbnails (no GL context over SSH) → Mainsail/Fluidd show no
  preview. Fix: render the part to square PNGs on the NUC and embed standard
  `; thumbnail begin` blocks with `pf_thumb.py` (this skill dir) **after**
  the estimator, before upload:
  ```
  # on the NUC, one PNG per size (small list icon + large detail)
  xvfb-run -a openscad -o /tmp/p_300.png --imgsize=300,300 --viewall --autocenter -D 'part="funnel"' bulk_hopper_module.scad
  xvfb-run -a openscad -o /tmp/p_48.png  --imgsize=48,48   --viewall --autocenter -D 'part="funnel"' bulk_hopper_module.scad
  scp /tmp/p_300.png /tmp/p_48.png pf_thumb.py macmini:/tmp/pf_slice/
  # on the Mac
  python3 pf_thumb.py g_<name>/plate_1.gcode /tmp/pf_slice/p_48.png /tmp/pf_slice/p_300.png
  ```
  Moonraker's inotify scan extracts them into `.thumbs/` on upload. Verify:
  `curl -s 'http://localhost:81/server/files/metadata?filename=petFeeder/<file>' | grep -o thumbnail`.

## Upload to the Pi
```
SSH_AUTH_SOCK="$SOCK" scp OUT/plate_1.gcode \
  "rossano@192.168.88.102:AONE21_data/gcodes/petFeeder/<part>_monofilament PLA - dark_gray_<time>.gcode"
```
Filename convention there: `<part>_<filament>_<time>.gcode`. Then the user
prints from Mainsail/Fluidd (AONE21) → petFeeder folder.

## Gotchas
- macOS has **no `timeout`** — wrap the OUTER ssh (from the NUC) in the
  NUC's `timeout`, give the inner ssh `ConnectTimeout` + `< /dev/null`.
- Slice the **current** repo STLs, not the (older) models embedded in
  `petFeeder.3mf`. Regenerate first, e.g.
  `xvfb-run openscad -o /tmp/pw_housing.stl -D 'part="housing"' hardware/cad/openscad/paddle_wheel_module.scad`,
  then scp to `macmini:/tmp/pf_slice/`.
- Work dir on the Mac: `/tmp/pf_slice/` (ephemeral; recreate as needed).
