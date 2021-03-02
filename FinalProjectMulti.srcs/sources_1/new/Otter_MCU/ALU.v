`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.01.2021 22:05:29
// Design Name: 
// Module Name: ALU
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

//0000 add
//1000 sub
//0110 or
//0111 and
//0100 xor
//0101 srl
//0001 sll
//1101 sra
//0010 slt
//0011 sltu
//1001 copy(lui)


module ALU(A,B,alu_fun,out);
    parameter n = 32;
    input logic [n-1:0]A,B;
    input logic [3:0]alu_fun;
	output logic [n-1:0]out;
	
	always_comb begin
        case(alu_fun)
        4'b0000: out = A + B;                                   //add
        4'b1000: out = A - B;                                   //sub
        4'b0110: out = A | B;                                  //or
        4'b0111: out = A & B;                                  //and
        4'b0100: out = A ^ B;                                   //xor
	4'b0101: out = A >> B[4:0];                                  //srl
	4'b0001: out = A << B[4:0];                                  //sll
        4'b1101: out = $signed(A) >>> B[4:0];                    //sra
        4'b0010: out = ($signed(A)) < ($signed(B)) ? 1 : 0;     //slt
	4'b0011: out = (A < B) ? 1 : 0;                           //sltu
        4'b1001: out = A;                         //lui
        default: out = 32'h0000;
        endcase
    end
	
endmodule
