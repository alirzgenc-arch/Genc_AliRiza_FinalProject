# Value-free comparison of rebuilt (raw sandbox) vs frozen (project copy) outputs.
# Usage: python3 -I L3_compare.py <rebuilt_root> <frozen_root>   (prints file names, flags and counts only)
import csv, hashlib, sys, os
R, F = sys.argv[1], sys.argv[2]
TOL = 1e-8
pairs = [  # file, key columns
 ("reports/qa/cis_raw_inventory.csv", None), ("reports/qa/music_file_inventory.csv", None),
 ("reports/qa/missing_and_duplicates.csv", None), ("data/interim/cis_vox_extracted.csv", ["study_id"]),
 ("reports/qa/cis_extraction_qa.csv", ["study_id"]), ("data/interim/cis_vox_manual_check.csv", ["study_id"]),
 ("data/processed/cis_vox_verified.csv", ["study_id"]), ("data/interim/poll_calendar_monthly.csv", ["origin"]),
 ("reports/qa/poll_feasibility_origins.csv", None), ("reports/qa/poll_feasibility_summary.txt", None),
 ("reports/qa/artist_name_audit.csv", ["artist_key", "spelling"]), ("data/interim/music_monthly.csv", None),
 ("reports/qa/music_feature_qa.csv", None), ("data/processed/model_frame_monthly.csv", ["origin"]),
 ("reports/qa/model_frame_qa.txt", None)]
sha = lambda p: hashlib.sha256(open(p, "rb").read()).hexdigest()
def rows(p):
    with open(p, encoding="utf-8-sig", newline="") as f: return list(csv.DictReader(f))
def num(x):
    try: return float(x)
    except: return None
out = []
for f, keys in pairs:
    a, b = os.path.join(F, f), os.path.join(R, f)
    if not os.path.exists(b): out.append((f, "MISSING in rebuild", "FAIL")); continue
    if sha(a) == sha(b): out.append((f, "byte-identical", "PASS")); continue
    if f.endswith(".txt"):
        la, lb = open(a).read().splitlines(), open(b).read().splitlines()
        diff = [i for i, (x, y) in enumerate(zip(la, lb)) if x != y]
        out.append((f, f"text differs: {len(la)} vs {len(lb)} lines; differing line numbers {diff[:8]}", "CHECK")); continue
    ra, rb = rows(a), rows(b)
    ca, cb = list(ra[0].keys()) if ra else [], list(rb[0].keys()) if rb else []
    if keys is None:
        keys = [c for c in ca if c in ("origin", "month", "month_m1", "artist_key", "relative_path", "file", "study_id", "week_end", "design")][:3] or ca[:1]
    ka = {tuple(r[k] for k in keys): r for r in ra}; kb = {tuple(r[k] for k in keys): r for r in rb}
    diffcols = {}
    for k in ka:
        if k not in kb: continue
        for c in ca:
            if c not in cb: continue
            x, y = ka[k][c], kb[k][c]
            if x == y: continue
            nx, ny = num(x), num(y)
            if nx is not None and ny is not None and abs(nx - ny) < TOL: continue
            diffcols[c] = diffcols.get(c, 0) + 1
    msg = (f"rows {len(ra)} vs {len(rb)}; keys {keys} equal={set(ka)==set(kb)}; cols equal={ca==cb}; "
           f"cells differing beyond {TOL}: {diffcols if diffcols else 'none'}")
    st = "PASS" if set(ka) == set(kb) and ca == cb and not diffcols and len(ra) == len(rb) else "CHECK"
    out.append((f, msg, st))
w = csv.writer(open(os.path.join(R, "L3_compare.csv"), "w", newline="")); w.writerow(["file", "result", "status"]); w.writerows(out)
for o in out: print(" | ".join(o))
