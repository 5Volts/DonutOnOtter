`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.02.2021 14:34:03
// Design Name: 
// Module Name: Otter
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

module plus4(
    input logic [31:0] in,
    output logic [31:0] out
    );
    always_comb begin
        out = in + 4;
    end
endmodule

module ImmedGen(
    input logic [31:0] ir,
	output logic [31:0] UType,
	output logic [31:0] IType,
	output logic [31:0] SType,
	output logic [31:0] BType,
	output logic [31:0] JType
	);
    
	always_comb begin
    	IType = {{21{ir[31]}}, ir[30:20]};
    	SType = {{21{ir[31]}}, ir[30:25], ir[11:8], ir[7]};
    	BType = {{20{ir[31]}}, ir[7], ir[30:25], ir[11:8], 1'b0};
    	UType = {ir[31], ir[30:20], ir[19:12], {12{1'b0}} };
    	JType = {{12{ir[31]}}, ir[19:12], ir[20], ir[30:25], ir[24:21], 1'b0};
	end
endmodule

module TargetGen(
    input logic [31:0] JType,
    input logic [31:0] BType,
    input logic [31:0] IType,
    input logic [31:0] RegOut1,
    input logic [31:0] PCOut,
    output logic[31:0] jalr,
    output logic[31:0] branch,
    output logic[31:0] jal
    );
    always_comb begin
        jalr = RegOut1 + IType;
        branch = PCOut + BType;
        jal = PCOut + JType;
    end
endmodule

module BRANCH_COND_GEN(
	input [31:0] rs1, [31:0]rs2,
	output logic br_eq, br_lt, br_ltu
	);
    
	always_comb begin
		br_eq = ($signed(rs1) == $signed(rs2)) ? 1 : 0;
        br_lt = ($signed(rs1) < $signed(rs2)) ? 1 : 0;
        br_ltu = (rs1 < rs2) ? 1 : 0;
	end
endmodule


module OTTER_MCU(
    input CLK,
    input INTR,
    input RESET,
    input [31:0]IOBUS_IN,
    output logic [31:0]IOBUS_OUT,
    output logic [31:0]IOBUS_ADDR,
    output logic IOBUS_WR
    );
    logic [31:0] pc4,jalr, branch,jal, pcmuxout, pcout, rs2,alu_out, rs1;
    logic memRead1, memRead2, pcWrite, pcReset, regWrite, memWrite, alu_srcA;
    logic [1:0] alu_srcB, rf_wr_sel, pcSource;
    logic [3:0] alu_fun;
    logic [31:0] memDout1;
    logic [31:0] regWd, CSR_reg, memDout2;
    logic [31:0] Utype, Itype, Stype, Btype, Jtype, alumux1out, alumux2out;
    logic clk = CLK;
    
    MUX_4to1 pcmux(
    .input0(pc4),
    .input1(jalr),
    .input2(branch),
    .input3(jal),
    .select_line(pcSource),
    .output_32bit(pcmuxout)
    );

    PC pc_(
    .clock(clk),
    .instruction_line(pcmuxout), 
    .PC_Reset(pcReset),
    .PC_Write(pcWrite),
    .mem_addr(pcout)
    );
    
    plus4 P4(
    .in(pcout),
    .out(pc4)
    );
    
    OTTER_mem_byte Mem(
    .MEM_ADDR1(pcout),
    .MEM_ADDR2(alu_out),
    .MEM_DIN2(rs2),
    .MEM_DOUT2(memDout2),
    .MEM_READ2(memRead2),
    .MEM_SIZE(memDout1[13:12]),
    .IO_WR(IOBUS_WR),
    .MEM_CLK(clk),
    .MEM_WRITE2(memWrite),
    .IO_IN(IOBUS_IN),
    .MEM_READ1(memRead1),
    .MEM_DOUT1(memDout1),
    .MEM_SIGN(memDout1[14]),
    .ERR(err)
    );
    
    MUX_4to1 wdmux(
    .input0(pc4),
    .input1(CSR_reg),
    .input2(memDout2),
    .input3(alu_out),
    .select_line(rf_wr_sel),
    .output_32bit(regWd)
    );
    

    Reg_File regfile(
    .ADR1(memDout1[19:15]),
    .ADR2(memDout1[24:20]),
    .WADR(memDout1[11:7]),
    .RF_WR(regWrite),
    .DATA_IN(regWd),
    .clk(clk),
    .D1_OUT(rs1),
    .D2_OUT(rs2)
     );
	
    MUX_2to1 alumux1(
    .input0(rs1),
    .input1(Utype),
    .select_line(alu_srcA),
    .output_32bit(alumux1out)
    );
    
    MUX_4to1 alumux2( 
    .input0(rs2),
    .input1(Itype),
    .input2(Stype),
    .input3(pcout),
    .select_line(alu_srcB),
    .output_32bit(alumux2out)
    );
	
    ALU alu(
    .A(alumux1out),	
    .B(alumux2out),
    .alu_fun(alu_fun),
    .out(alu_out)
    );

    BRANCH_COND_GEN bcg(
        .rs1(rs1),
        .rs2(rs2),
        .br_eq(breq),
        .br_lt(brlt),
        .br_ltu(brltu)
    );
    CU_Decoder decoder(
	    .br_eq(breq),
	    .br_lt(brlt),
	    .br_ltu(brltu),
	    .alu_fun(alu_fun),
	    .alu_srcA(alu_srcA),
	    .alu_srcB(alu_srcB),
	    .pcSource(pcSource),
	    .rf_wr_sel(rf_wr_sel),
	    .ir(memDout1)
    );
		
    CU_FSM fsm(
		.clk(clk),
		.INT_(INTR),
		.RST(RESET),
		.ir(memDout1[6:0]),
		.pcWrite(pcWrite),
		.regWrite(regWrite),
		.memWrite(memWrite),
		.memRead1(memRead1),
		.memRead2(memRead2)
	);
	
	    ImmedGen imgen(
        .ir(memDout1),
        .UType(Utype),
        .IType(Itype),
        .SType(Stype),
        .BType(Btype),
        .JType(Jtype)
        );
        
        TargetGen targen(
        .JType(Jtype),
        .BType(Btype),
        .IType(Itype),
        .RegOut1(rs1),
        .PCOut(pcout),
        .jalr(jalr),
        .branch(branch),
        .jal(jal)
        );
	
    
	    
    assign IOBUS_OUT = rs2;
    assign IOBUS_ADDR = alu_out;
    

endmodule
