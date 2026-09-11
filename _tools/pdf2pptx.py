"""
PDF → PPTX 批次轉檔
每頁 PDF 轉為一張高解析度圖片，嵌入 PPT 投影片（16:9 版面，全頁填滿）。
用法：python pdf2pptx.py <pdf_dir> [output_dir]
"""

import sys, os, io, glob, time
import fitz                      # PyMuPDF
from pptx import Presentation
from pptx.util import Emu

# ---------- 設定 ----------
DPI = 200          # 解析度，200 DPI 在投影片上已經很清晰
SLIDE_W = Emu(12192000)   # 16:9 寬 (33.867 cm)
SLIDE_H = Emu(6858000)    # 16:9 高 (17.145 cm)
# ---------------------------

def pdf_to_pptx(pdf_path: str, output_path: str):
    """把一份 PDF 轉成一份 PPTX（每頁 → 一張投影片）"""
    doc = fitz.open(pdf_path)
    prs = Presentation()
    prs.slide_width = SLIDE_W
    prs.slide_height = SLIDE_H
    blank_layout = prs.slide_layouts[6]   # 空白版面

    total = len(doc)
    for i, page in enumerate(doc):
        # 將 PDF 頁面渲染成 PNG 圖片
        mat = fitz.Matrix(DPI / 72, DPI / 72)
        pix = page.get_pixmap(matrix=mat, alpha=False)
        img_bytes = pix.tobytes("png")

        # 計算圖片在投影片中的位置（置中、等比縮放）
        img_w = pix.width
        img_h = pix.height
        scale_w = SLIDE_W / img_w
        scale_h = SLIDE_H / img_h
        scale = min(scale_w, scale_h)

        pic_w = int(img_w * scale)
        pic_h = int(img_h * scale)
        left = (SLIDE_W - pic_w) // 2
        top  = (SLIDE_H - pic_h) // 2

        slide = prs.slides.add_slide(blank_layout)
        slide.shapes.add_picture(
            io.BytesIO(img_bytes), left, top, pic_w, pic_h
        )
        print(f"  [{i+1}/{total}] 頁面已轉換", end="\r")

    prs.save(output_path)
    doc.close()
    print(f"  [OK] {total} pages -> {os.path.basename(output_path)}")


def main():
    if len(sys.argv) < 2:
        print("用法：python pdf2pptx.py <pdf_dir> [output_dir]")
        sys.exit(1)

    pdf_dir = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else os.path.join(pdf_dir, "pptx_output")
    os.makedirs(output_dir, exist_ok=True)

    pdf_files = sorted(glob.glob(os.path.join(pdf_dir, "*.pdf")))
    if not pdf_files:
        print("[ERROR] No PDF files found.")
        sys.exit(1)

    print(f"Source: {pdf_dir}")
    print(f"Output: {output_dir}")
    print(f"Total : {len(pdf_files)} PDF files\n")

    t0 = time.time()
    for idx, pdf_path in enumerate(pdf_files, 1):
        basename = os.path.splitext(os.path.basename(pdf_path))[0]
        out_path = os.path.join(output_dir, basename + ".pptx")
        print(f"[{idx}/{len(pdf_files)}] {os.path.basename(pdf_path)}")
        pdf_to_pptx(pdf_path, out_path)

    elapsed = time.time() - t0
    print(f"\n[DONE] All finished! Elapsed: {elapsed:.1f}s")


if __name__ == "__main__":
    main()
