`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.02.2021 14:30:11
// Design Name: 
// Module Name: PC
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


module PC (
    input logic clock,
    input logic [31:0] instruction_line,
    input PC_Reset,
    input PC_Write,
    output logic [31:0] mem_addr
    );
//    mem_addr = 32'h00000000;
//    initial begin
//    assign mem_addr = 32'h00000000;
//    end
    always_ff  @ (posedge clock) begin
        if (PC_Reset) begin
            mem_addr <= 0;
        end
        else if (PC_Write) begin
            mem_addr <= instruction_line;
        end
        else begin
            mem_addr = mem_addr;
        end
   end
endmodule

module MUX_4to1(
    input logic [31:0] input0,
    input logic [31:0] input1,
    input logic [31:0] input2, 
    input logic [31:0] input3,
    input [1:0] select_line,
    output logic [31:0] output_32bit
    );
    always_comb begin
        case(select_line)
        2'b00: output_32bit = input0;
        2'b01: output_32bit = input1;
        2'b10: output_32bit = input2;
        2'b11: output_32bit = input3;
        endcase
    end
endmodule

module MUX_2to1(
    input logic [31:0] input0,
    input logic [31:0] input1,
    input logic select_line,
    output logic [31:0] output_32bit
    );
    always_comb begin
        case(select_line)
        1'b0: output_32bit = input0;
        1'b1: output_32bit = input1;
        endcase
    end
endmodule
