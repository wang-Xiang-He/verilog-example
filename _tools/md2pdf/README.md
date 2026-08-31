# md2pdf

把 `verilog-example/` 底下的 Markdown 筆記（含表格、Verilog 程式碼區塊、LaTeX 數學式）轉成排版好看的 PDF。
使用 Edge/Chrome 無頭瀏覽器列印，不需要安裝 Pandoc 或 LaTeX。

## 安裝（只需做一次）

```bash
cd _tools/md2pdf
npm install
```

需要電腦上已安裝 Microsoft Edge 或 Google Chrome（Windows 內建 Edge 通常就足夠）。

## 用法

### 轉換全部檔案（批次）

```bash
node convert.js --all
# 或
npm run all
```

會遞迴掃描專案根目錄底下所有 `.md` 檔案（略過 `_tools/`、`node_modules/`、`.git/`），
每個檔案輸出成同資料夾、同檔名的 `.pdf`（例如 `week06_fsm/README.md` -> `week06_fsm/README.pdf`）。

### 只轉換單一檔案（修改後重新產生）

```bash
node convert.js ../../explain.md
node convert.js ../../COURSE.md ../../HOWTO.md
```

## 備註

- PDF 會覆寫同名的舊檔案，所以修改 md 後直接重跑就能更新。
- 若要用其他瀏覽器路徑，設定環境變數 `CHROME_PATH` 指向 exe 即可。
