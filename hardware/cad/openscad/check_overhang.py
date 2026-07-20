#!/usr/bin/env python3
"""Report every downward-facing facet in a binary STL that overhangs more than a limit.

Print geometry rule: a facet is self-supporting while its surface is no more than `limit`
degrees away from vertical. Measure it from the facet NORMAL: for a downward normal the
angle from straight-down is acos(-nz); the overhang measured from vertical is 90 - that.
So a vertical wall (nz=0) overhangs 0°, a flat ceiling (nz=-1) overhangs 90°.

Areas are reported because a handful of tessellation slivers is noise, while a real ledge
shows up as tens of mm².

    python3 check_overhang.py part.stl [limit_deg]
"""
import struct, math, sys
from collections import defaultdict


def facets(path):
    with open(path, "rb") as f:
        f.read(80)
        n = struct.unpack("<I", f.read(4))[0]
        body = f.read()
    for i in range(n):
        v = struct.unpack("<12f", body[i * 50:i * 50 + 48])
        yield v[0:3], (v[3:6], v[6:9], v[9:12])


def tri_area(a, b, c):
    ux, uy, uz = b[0] - a[0], b[1] - a[1], b[2] - a[2]
    vx, vy, vz = c[0] - a[0], c[1] - a[1], c[2] - a[2]
    cx, cy, cz = uy * vz - uz * vy, uz * vx - ux * vz, ux * vy - uy * vx
    return math.hypot(cx, math.hypot(cy, cz)) / 2.0


def main(path, limit=45.0):
    buckets = defaultdict(float)
    worst = []
    total_bad = 0.0
    for (nx, ny, nz), (a, b, c) in facets(path):
        norm = math.sqrt(nx * nx + ny * ny + nz * nz)
        if norm == 0:
            continue
        nz /= norm
        if nz >= 0:
            continue                      # faces up or sideways-up: never an overhang
        from_down = math.degrees(math.acos(min(1.0, -nz)))
        overhang = 90.0 - from_down       # 0 = vertical wall, 90 = flat ceiling
        if overhang <= limit + 1e-6:
            continue
        area = tri_area(a, b, c)
        total_bad += area
        buckets[int(overhang // 10) * 10] += area
        zmid = (a[2] + b[2] + c[2]) / 3.0
        worst.append((overhang, area, zmid))

    print(f"  {path}")
    if not worst:
        print(f"  OK — no facet overhangs more than {limit:.0f}deg")
        return 0
    worst.sort(key=lambda t: -t[1])
    print(f"  {len(worst)} facets exceed {limit:.0f}deg, total area {total_bad:.1f} mm2")
    for lo in sorted(buckets):
        print(f"    {lo:3d}-{lo+10:3d}deg : {buckets[lo]:8.1f} mm2")
    print("  largest offenders (overhang, area, z):")
    for o, ar, z in worst[:8]:
        print(f"    {o:5.1f}deg  {ar:7.2f} mm2  at z={z:6.1f}")
    return 1


if __name__ == "__main__":
    lim = float(sys.argv[2]) if len(sys.argv) > 2 else 45.0
    sys.exit(main(sys.argv[1], lim))
