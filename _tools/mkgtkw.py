#!/usr/bin/env python3
"""
mkgtkw.py ── 從 .vcd 自動產生 GTKWave 設定檔 (.gtkw)

用法:  python mkgtkw.py <wave.vcd> <輸出.gtkw>

自動做三件事：
  1. 抓出 testbench 最上層的所有訊號（跳過迴圈用的 integer）
  2. 每條配一個顏色，多位元的用十進位顯示
  3. 依照模擬總長度算出剛好塞滿畫面的縮放倍率
"""
import sys, os, math, re

WIDTH_PX = 1400          # GTKWave 波形區大約的寬度
COLORS = [3, 1, 2, 4, 5, 6, 7]   # Yellow Red Orange Green Blue Indigo Violet


def parse_vcd(path):
    """回傳 (最上層 scope 名, [(名稱, 位元數), ...], 模擬總時間)"""
    top = None
    sigs = []
    depth = 0
    last_time = 0
    in_defs = True

    with open(path, encoding="utf-8", errors="replace") as f:
        for line in f:
            s = line.strip()
            if in_defs:
                if s.startswith("$scope"):
                    depth += 1
                    if depth == 1:
                        top = s.split()[2]
                elif s.startswith("$upscope"):
                    depth -= 1
                elif s.startswith("$var") and depth == 1:
                    # $var wire 4 ! count [3:0] $end
                    p = s.split()
                    vtype, width, name = p[1], int(p[2]), p[4]
                    if vtype == "integer":       # 迴圈計數器之類，不畫
                        continue
                    sigs.append((name, width))
                elif s.startswith("$enddefinitions"):
                    in_defs = False
            else:
                if s.startswith("#"):
                    try:
                        last_time = int(s[1:])
                    except ValueError:
                        pass

    return top, sigs, last_time


def make(vcd_path, out_path):
    top, sigs, total = parse_vcd(vcd_path)
    if not top or not sigs:
        print("  [!] 這個 VCD 抓不到訊號，跳過")
        return False

    zoom = math.log2(WIDTH_PX / total) if total > 0 else 0.0

    vcd_abs = os.path.abspath(vcd_path)
    out_abs = os.path.abspath(out_path)

    lines = [
        "[*] GTKWave save file (mkgtkw.py 自動產生)",
        '[dumpfile] "%s"' % vcd_abs,
        '[savefile] "%s"' % out_abs,
        "[timestart] 0",
        "[size] 1280 720",
        "[pos] -1 -1",
        "*%f -1 -1 -1 -1 -1 -1 -1" % zoom,
        "[treeopen] %s." % top,
        "[sst_width] 250",
        "[signals_width] 220",
        "[sst_expanded] 1",
        "[pattern_trace] 1",
        "[pattern_trace] 0",
    ]

    prev_fmt = None
    for i, (name, width) in enumerate(sigs):
        fmt = "@28" if width == 1 else ("@24" if width <= 8 else "@22")
        if fmt != prev_fmt:
            lines.append(fmt)
            prev_fmt = fmt
        lines.append("[color] %d" % COLORS[i % len(COLORS)])
        lines.append("%s.%s" % (top, name))

    lines += ["[pattern_trace] 1", "[pattern_trace] 0"]

    with open(out_path, "w", encoding="utf-8", newline="\r\n") as f:
        f.write("\n".join(lines) + "\n")

    print("  %s  (%d 條訊號, 總長 %d, zoom %.2f)"
          % (os.path.basename(out_path), len(sigs), total, zoom))
    return True


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(1)
    sys.exit(0 if make(sys.argv[1], sys.argv[2]) else 1)
