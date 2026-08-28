`timescale 1ns / 1ps
module pattern_fsm (
    input  wire       clk,
    input  wire       rst,
    input  wire [1:0] key,
    input  wire       key_valid,
    output reg        unlock,
    output wire [1:0] state_out
);
    localparam S0 = 2'd0, S1 = 2'd1, S2 = 2'd2, S3 = 2'd3;

    reg [1:0] state, next_state;
    assign state_out = state;

    always @(posedge clk) begin
        if (rst) state <= S0;
        else     state <= next_state;
    end

    always @(*) begin
        next_state = state;
        if (key_valid) begin
            case (state)
                S0: next_state = (key == 2'd1) ? S1 : S0;
                S1: next_state = (key == 2'd2) ? S2 :
                                 (key == 2'd1) ? S1 : S0;
                S2: next_state = (key == 2'd3) ? S3 :
                                 (key == 2'd1) ? S1 : S0;
                S3: next_state = (key == 2'd1) ? S1 : S0;
                default: next_state = S0;
            endcase
        end
    end

    always @(posedge clk) begin
        if (rst) unlock <= 1'b0;
        else     unlock <= key_valid && (state == S3) && (key == 2'd0);
    end
endmodule
