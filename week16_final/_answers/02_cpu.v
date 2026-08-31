// ============================================================
//  期末專題 第 2 題：簡易 8-bit CPU —— 解答
// ============================================================
`timescale 1ns / 1ps

module cpu (
    input  wire       clk,
    input  wire       rst_n,
    output wire [5:0] pc_out,
    output wire [7:0] acc_out,
    output wire [7:0] ir_out,
    output wire [1:0] state_out,
    output wire       halted,
    input  wire       load_en,
    input  wire [5:0] load_addr,
    input  wire [7:0] load_data,
    input  wire [5:0] peek_addr,
    output wire [7:0] peek_data
);

    localparam S_FETCH  = 2'd0,
               S_DECODE = 2'd1,
               S_EXEC   = 2'd2;

    localparam OP_LDA = 2'b00,
               OP_ADD = 2'b01,
               OP_STA = 2'b10,
               OP_JMP = 2'b11;

    reg [7:0] mem [0:63];
    reg [5:0] pc;
    reg [7:0] acc;
    reg [7:0] ir;
    reg [1:0] state;
    reg       halt_r;

    //  指令解碼（純接線，不用邏輯）
    wire [1:0] opcode = ir[7:6];
    wire [5:0] addr   = ir[5:0];

    assign pc_out    = pc;
    assign acc_out   = acc;
    assign ir_out    = ir;
    assign state_out = state;
    assign halted    = halt_r;

    //  給測試平台看的非同步讀取埠（真實 CPU 不會有）
    assign peek_data = mem[peek_addr];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc     <= 6'd0;
            acc    <= 8'd0;
            ir     <= 8'd0;
            state  <= S_FETCH;
            halt_r <= 1'b0;

            //  reset 期間允許外部載入程式
            if (load_en) mem[load_addr] <= load_data;

        end else if (load_en) begin
            //  載入模式：CPU 暫停，只寫記憶體
            mem[load_addr] <= load_data;

        end else if (!halt_r) begin
            case (state)

                // ------------------------------------------------
                //  取指令：ir <- mem[pc]，pc 往前走一格
                // ------------------------------------------------
                S_FETCH: begin
                    ir    <= mem[pc];
                    pc    <= pc + 1'b1;
                    state <= S_DECODE;
                end

                // ------------------------------------------------
                //  解碼：這一拍主要是等記憶體讀出來穩定
                //  （ir 是上一拍才寫進去的，這一拍才讀得到）
                // ------------------------------------------------
                S_DECODE: begin
                    state <= S_EXEC;
                end

                // ------------------------------------------------
                //  執行
                // ------------------------------------------------
                S_EXEC: begin
                    case (opcode)
                        OP_LDA: acc <= mem[addr];
                        OP_ADD: acc <= acc + mem[addr];
                        OP_STA: mem[addr] <= acc;
                        OP_JMP: begin
                            //  ★ FETCH 時 pc 已經 +1 了，這裡直接覆蓋
                            pc <= addr;
                            //  ★ 跳回自己 → 無窮迴圈 → 視為程式結束
                            if (addr == (pc - 1'b1)) halt_r <= 1'b1;
                        end
                    endcase
                    state <= S_FETCH;
                end

                default: state <= S_FETCH;
            endcase
        end
    end

endmodule
