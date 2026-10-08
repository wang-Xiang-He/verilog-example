`timescale 1ns/1ps

// =====================================================================
// Sort_4_Data：4 筆資料由小到大排序，ra <= rb <= rc <= rd（講義第 15~17 頁）
//   用任務 Sort_2_Data「比較並交換」兩筆資料，呼叫 5 次就能排好 4 筆
// =====================================================================
module Sort_4_Data #(
    parameter size = 4 - 1      // 最高位元的編號：資料寬度是 size+1 = 4 位元
) (
    input      [size:0] a,
    input      [size:0] b,
    input      [size:0] c,
    input      [size:0] d,
    output reg [size:0] ra,
    output reg [size:0] rb,
    output reg [size:0] rc,
    output reg [size:0] rd
);
    always @(*) begin : Label_Name      // 講義：always @(a or b or c or d)
        // 區塊有名字（Label_Name）才能在裡面宣告區域變數
        reg [size:0] va, vb, vc, vd;

        {va, vb, vc, vd} = {a, b, c, d};
        Sort_2_Data(va, vc);            // 例 (3,1,4,2) → (3,1,4,2)
        Sort_2_Data(vb, vd);            //             → (3,1,4,2)
        Sort_2_Data(va, vb);            //             → (1,3,4,2)   va 是最小值
        Sort_2_Data(vc, vd);            //             → (1,3,2,4)   vd 是最大值
        Sort_2_Data(vb, vc);            //             → (1,2,3,4)
        {ra, rb, rc, rd} = {va, vb, vc, vd};
    end

    // 任務：x > y 就交換。x、y 是 inout：值傳進來，任務結束時再傳回去
    //   講義（1995）寫法：task Sort_2_Data;  inout [size:0] x, y;
    task Sort_2_Data (
        inout [size:0] x,
        inout [size:0] y
    );
        reg [size:0] temp;
        begin
            if (x > y) begin            // 交換（Swap）
                temp = x;
                x = y;
                y = temp;
            end
        end
    endtask
endmodule
