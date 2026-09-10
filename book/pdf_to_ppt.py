"""
pdf_to_ppt.py
=============
將 chapters/ 資料夾內所有 PDF 轉成 PPTX 檔，輸出到同資料夾。

用法：
    python pdf_to_ppt.py                        # 轉換所有 PDF（跳過已存在）
    python pdf_to_ppt.py -f chp1.pdf chp2.pdf  # 只轉指定檔案
    python pdf_to_ppt.py -o                     # 強制覆蓋所有已存在的 PPTX
    python pdf_to_ppt.py -f chp1.pdf -o        # 指定檔案 + 強制覆蓋

依賴套件（請先執行）：
    pip install pdf2image python-pptx pillow
    # Windows 還需要 poppler：
    #   1. 下載 https://github.com/oschwartz10612/poppler-windows/releases
    #   2. 解壓後將 bin/ 路徑加入 PATH，或在下方設定 POPPLER_PATH
"""

import sys
import os
import argparse
from pathlib import Path

# ── 設定 ──────────────────────────────────────────────────────────────────────
# 若 poppler 的 bin/ 不在 PATH，請把路徑填在這裡，例如：
#   POPPLER_PATH = r"C:\poppler\Library\bin"
POPPLER_PATH = r"C:\Users\a9100\.gemini\poppler\poppler-24.08.0\Library\bin"

DPI         = 150            # 解析度（越高品質越好但速度較慢）
SLIDE_W_PT  = 960            # 投影片寬度（pt）= 1280px / 96dpi * 72
SLIDE_H_PT  = 540            # 投影片高度（pt）= 720px / 96dpi * 72
# ─────────────────────────────────────────────────────────────────────────────


def check_dependencies():
    """確認必要套件已安裝"""
    missing = []
    try:
        import pdf2image  # noqa
    except ImportError:
        missing.append("pdf2image")
    try:
        import pptx  # noqa
    except ImportError:
        missing.append("python-pptx")
    try:
        from PIL import Image  # noqa
    except ImportError:
        missing.append("pillow")

    if missing:
        print("缺少套件，請先安裝：")
        print(f"   pip install {' '.join(missing)}")
        sys.exit(1)


def pdf_to_pptx(pdf_path: Path, output_path: Path):
    """將單一 PDF 轉成 PPTX"""
    from pdf2image import convert_from_path
    from pptx import Presentation
    from pptx.util import Pt
    import tempfile

    print(f"  轉換中：{pdf_path.name}")

    convert_kwargs = dict(dpi=DPI)
    if POPPLER_PATH:
        convert_kwargs["poppler_path"] = POPPLER_PATH

    images = convert_from_path(str(pdf_path), **convert_kwargs)
    total = len(images)
    print(f"     共 {total} 頁")

    prs = Presentation()
    prs.slide_width  = Pt(SLIDE_W_PT)
    prs.slide_height = Pt(SLIDE_H_PT)

    blank_layout = prs.slide_layouts[6]

    with tempfile.TemporaryDirectory() as tmp_dir:
        for i, img in enumerate(images, start=1):
            img_path = os.path.join(tmp_dir, f"page_{i:04d}.png")
            img.save(img_path, "PNG")

            slide = prs.slides.add_slide(blank_layout)
            slide.shapes.add_picture(
                img_path,
                left=0, top=0,
                width=prs.slide_width,
                height=prs.slide_height,
            )

            if i % 10 == 0 or i == total:
                print(f"     進度：{i}/{total}", end="\r")

    prs.save(str(output_path))
    print(f"\n  已儲存：{output_path.name}")


def parse_args():
    parser = argparse.ArgumentParser(
        description="將 PDF 轉成 PPTX（每頁轉為投影片）",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="範例:\n"
               "  python pdf_to_ppt.py                        # 轉換全部\n"
               "  python pdf_to_ppt.py -f chp1.pdf chp2.pdf  # 指定檔案\n"
               "  python pdf_to_ppt.py -o                     # 強制覆蓋\n"
               "  python pdf_to_ppt.py -f chp1.pdf -o        # 指定 + 覆蓋",
    )
    parser.add_argument(
        "-f", "--file",
        nargs="+",
        metavar="PDF",
        help="指定要轉換的 PDF 檔名（可多個，不含路徑或含路徑皆可）；省略則轉換 chapters/ 內全部",
    )
    parser.add_argument(
        "-o", "--overwrite",
        action="store_true",
        help="強制覆蓋已存在的 PPTX 檔案",
    )
    return parser.parse_args()


def main():
    args = parse_args()

    script_dir   = Path(__file__).parent
    chapters_dir = script_dir / "chapters"
    output_dir   = script_dir

    check_dependencies()

    # ── 決定要轉哪些 PDF ──────────────────────────────────────────
    if args.file:
        pdf_files = []
        for name in args.file:
            p = Path(name)
            # 若沒有目錄部分，預設在 chapters/ 找
            if not p.parent.name or p.parent == Path("."):
                p = chapters_dir / p.name
            if not p.exists():
                print(f"  找不到檔案：{p}")
                continue
            pdf_files.append(p)
        pdf_files = sorted(pdf_files)
    else:
        pdf_files = sorted(chapters_dir.glob("*.pdf"))

    if not pdf_files:
        print(f"沒有可轉換的 PDF 檔案")
        sys.exit(0)

    print(f"找到 {len(pdf_files)} 個 PDF 檔案，開始轉換...\n")

    success = 0
    failed  = []

    for pdf in pdf_files:
        output_path = output_dir / (pdf.stem + ".pptx")

        if output_path.exists() and not args.overwrite:
            print(f"  跳過（已存在，加 -o 可覆蓋）：{output_path.name}")
            success += 1
            continue

        try:
            pdf_to_pptx(pdf, output_path)
            success += 1
        except Exception as e:
            print(f"  失敗：{pdf.name}\n     原因：{e}")
            failed.append(pdf.name)

    print(f"\n{'='*50}")
    print(f"成功：{success} 個   失敗：{len(failed)} 個")
    if failed:
        print("失敗清單：")
        for f in failed:
            print(f"  - {f}")


if __name__ == "__main__":
    main()
