#!/usr/bin/env python3
"""Slice STL(s) on the Mac with the AONE2 profile from petFeeder.3mf.

Run ON THE MAC (macmini). OrcaSlicer's --load-settings can't take the user
presets (inheritance) or a project config, so we: export each STL to a 3mf,
swap the AONE2 project config (from petFeeder.3mf, minus post_process) into
it, then slice that 3mf.

Usage (on the Mac):
    python3 pf_make.py <stl> <name> [<stl2> <name2> ...]
e.g.
    python3 pf_make.py /tmp/pf_slice/pw_housing.stl housing \
                       /tmp/pf_slice/pw_end_cap.stl  end_cap

Each part -> /tmp/pf_slice/g_<name>/plate_1.gcode  (then run
klipper_estimator on it and scp to the Pi; see SKILL.md).
"""
import json, zipfile, shutil, subprocess, os, sys

ORCA = "/Applications/OrcaSlicer.app/Contents/MacOS/OrcaSlicer"
PROJECT_3MF = os.path.expanduser("~/Downloads/petFeeder.3mf")  # profile source
WORK = "/tmp/pf_slice"

def prepare_config():
    os.makedirs(WORK, exist_ok=True)
    with zipfile.ZipFile(PROJECT_3MF) as z:
        cfg = json.loads(z.read("Metadata/project_settings.config"))
    cfg.pop("post_process", None)          # CLI can't run post-process scripts
    path = os.path.join(WORK, "pf_noproc.json")
    json.dump(cfg, open(path, "w"))
    return path

def slice_part(stl, name, noproc):
    mf = os.path.join(WORK, name + ".3mf")
    subprocess.run([ORCA, "--arrange", "1", "--export-3mf", mf, stl],
                   capture_output=True, text=True)
    if not os.path.exists(mf):
        print(name, "EXPORT FAILED"); return
    tmp = mf + ".tmp"
    with zipfile.ZipFile(mf) as zin, \
         zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as zout:
        for it in zin.namelist():
            data = open(noproc).read() if it == "Metadata/project_settings.config" \
                   else zin.read(it)
            zout.writestr(it, data)
    shutil.move(tmp, mf)
    outdir = os.path.join(WORK, "g_" + name)
    shutil.rmtree(outdir, ignore_errors=True); os.makedirs(outdir)
    r = subprocess.run([ORCA, "--no-check", "--arrange", "1", "--slice", "0",
                        "--outputdir", outdir, mf], capture_output=True, text=True)
    files = os.listdir(outdir)
    print(name, "rc", r.returncode, "->", os.path.join(outdir, files[0]) if files else files)
    if r.returncode or not files:
        print(r.stdout[-1000:]); print(r.stderr[-1000:])

if __name__ == "__main__":
    args = sys.argv[1:]
    if len(args) < 2 or len(args) % 2:
        sys.exit("usage: pf_make.py <stl> <name> [<stl2> <name2> ...]")
    noproc = prepare_config()
    for i in range(0, len(args), 2):
        slice_part(args[i], args[i + 1], noproc)
