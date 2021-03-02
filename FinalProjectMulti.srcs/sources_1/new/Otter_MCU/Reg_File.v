`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.01.2021 23:02:01
// Design Name: 
// Module Name: Reg_File
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Reg_File(
    input [4:0]ADR1,[4:0]ADR2, [4:0]WADR, [31:0]DATA_IN,
    input RF_WR, clk,
    output logic [31:0]D1_OUT, [31:0]D2_OUT 
    );
    logic [31:0] ram [0:31];
    initial begin
        int i;
        for (i=0; i<32; i++) begin
            ram[i] = 0;
        end
    end
    
    assign D1_OUT = (ADR1!=5'd0)?ram[ADR1]:32'd0;
    assign D2_OUT = (ADR2!=5'd0)?ram[ADR2]:32'd0;
//    assign D2_OUT= 32'h98765432 + (ADR2!=5'd0)?ram[ADR2]:32'd0;    
    always_ff @(posedge clk) begin
        if(RF_WR == 1 && WADR != 0) begin
            ram[WADR]<=DATA_IN;
        end
    end

endmodule
