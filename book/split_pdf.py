# -*- coding: utf-8 -*-
"""
PDF 章節拆分腳本
將 Verilog硬體描述語言數位電路設計實務.pdf 拆分成各個章節
"""
import sys, io, os
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
from PyPDF2 import PdfReader, PdfWriter

# 來源 PDF 路徑
SOURCE_PDF = r'book\Verilog硬體描述語言數位電路設計實務.pdf'
# 輸出目錄
OUTPUT_DIR = r'book\chapters'

# 章節定義：(起始頁, 結束頁, 檔名)
# 頁碼為 PDF 中的實際頁碼（1-indexed）
chapters = [
    (1,   40,   'chp1_數位電路的設計觀念'),
    (41,  106,  'chp2_Verilog硬體描述語言簡介'),
    (107, 144,  'chp3_Verilog的模組與架構'),
    (145, 182,  'chp4_能否用於電路合成'),
    (183, 214,  'chp5_Verilog常用的敘述'),
    (215, 236,  'chp6_Verilog訊號與變數'),
    (237, 262,  'chp7_算術運算'),
    (263, 306,  'chp8_組合邏輯電路'),
    (307, 348,  'chp9_循序邏輯電路'),
    (349, 384,  'chp10_有限狀態機器與CPU設計'),
    (385, 408,  'chp11_記憶體設計與應用'),
    (409, 450,  'chp12_進階課程'),
    (451, 524,  'chp13_Verilog2001增強特色'),
    (525, 550,  'chp14_Verilog檔案處理與除錯輔助功能'),
    (551, 560,  'chp15_User_Defined_Primitives'),
    (561, None, 'chp16_Verilog保留字'),  # None 表示到最後一頁
]

def split_pdf():
    print(f'正在讀取: {SOURCE_PDF}')
    reader = PdfReader(SOURCE_PDF)
    total_pages = len(reader.pages)
    print(f'PDF 總頁數: {total_pages}')
    
    # 建立輸出目錄
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    for start, end, name in chapters:
        if end is None:
            end = total_pages
        
        writer = PdfWriter()
        # PyPDF2 使用 0-indexed
        for page_num in range(start - 1, end):
            writer.add_page(reader.pages[page_num])
        
        output_path = os.path.join(OUTPUT_DIR, f'{name}.pdf')
        with open(output_path, 'wb') as f:
            writer.write(f)
        
        page_count = end - start + 1
        print(f'  ✓ {name}.pdf  ({page_count} 頁, 第 {start}-{end} 頁)')
    
    print(f'\n拆分完成！所有檔案已存放於: {OUTPUT_DIR}')

if __name__ == '__main__':
    split_pdf()
