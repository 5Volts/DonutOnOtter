`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.02.2021 21:29:55
// Design Name: 
// Module Name: CU_Decoder
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


module CU_Decoder(
    input logic br_eq, br_lt, br_ltu,
    input logic [31:0]ir,
    output logic [3:0]alu_fun,
    output logic alu_srcA,
    output logic [1:0]alu_srcB,
    output logic [1:0]pcSource, 
    output logic [1:0]rf_wr_sel
    );
    
    typedef enum logic[6:0] {
            LUI = 7'b0110111,
            AUIPC = 7'b0010111,
            JAL= 7'b1101111,
            JALR = 7'b1100111,
            BRANCH= 7'b1100011,
            LOAD = 7'b0000011,
            STORE = 7'b0100011,
            OP_IMM = 7'b0010011,
            OP= 7'b0110011
            }opcode_t;
        opcode_t OPCODE;//Define variable of newly defined type//Cast input bits as enum, for showing opcode names during simulation
        assign OPCODE = opcode_t'(ir);

    always_comb 
        casex({ir[6:0],ir[14:12],ir[31:25], br_eq, br_lt, br_ltu})
        20'b0110111xxxxxxxxxxxxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b10011000011;
        //lui c
        20'b0010111xxxxxxxxxxxxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00001110011;
        //auipc c
        20'b1101111xxxxxxxxxxxxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'bxxxxxxx1100;
        //jal c
        20'b1100111xxxxxxxxxxxxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000010100;//jalr c
        //branchtaken 
        20'b1100011000xxxxxxx1xx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000001000;//beq c 
        20'b1100011001xxxxxxx0xx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000001000;//bne c
        20'b1100011100xxxxxxxx1x:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000001000;//blt c
        20'b1100011101xxxxxxx1xx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000001000;//bge c
        20'b1100011101xxxxxxxx0x:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000001000;//bge c
        20'b1100011110xxxxxxxxx1:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000001000;//bltu c
        20'b1100011111xxxxxxx1xx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000001000;//bgeu c
        20'b1100011111xxxxxxxxx0:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000001000;//bgeu c
        //branchnottaken
        20'b1100011000xxxxxxx0xx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000000000;//beq c
        20'b1100011001xxxxxxx1xx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000000000;//bne c
        20'b1100011100xxxxxxxx0x:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000000000;//blt c
        20'b1100011101xxxxxxx0xx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000000000;//bge c
        20'b1100011101xxxxxxxx1x:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000000000;//bge c
        20'b1100011110xxxxxxxxx0:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000000000;//bltu c
        20'b1100011111xxxxxxx0xx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000000000;//bgeu c
        20'b1100011111xxxxxxxxx1:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000000000;//bgeu c
        
        20'b0000011000xxxxxxxxxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000010010;//LB c
        20'b0000011001xxxxxxxxxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000010010;//LH c
        20'b0000011010xxxxxxxxxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000010010;//LW c
        20'b0000011100xxxxxxxxxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000010010;//LBU c
        20'b0000011101xxxxxxxxxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000010010;//LHU c
        
        20'b0100011000xxxxxxxxxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000100010;//SB c
        20'b0100011001xxxxxxxxxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000100010;//SH c
        20'b0100011010xxxxxxxxxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000100010;//SW c
        
        20'b0010011000xxxxxxxxxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000010011;//ADDI c
        20'b0010011010xxxxxxxxxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00100010011;//SLTI c
        20'b0010011011xxxxxxxxxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00110010011;//SLTIU c  
        20'b0010011100xxxxxxxxxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b01000010011;//XORI c   
        20'b0010011110xxxxxxxxxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b01100010011;//ORI c     
        20'b0010011111xxxxxxxxxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b01110010011;//ANDI c 
        20'b00100110010000000xxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00010010011;//SLLI c
        20'b00100111010000000xxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b01010010011;//SRLI c
        20'b00100111010100000xxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b11010010011;//SRAI c
        
        20'b01100110000000000xxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000000011;//ADD      
        20'b01100110000100000xxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b10000000011;//SUB     
        20'b0110011001xxxxxxxxxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00010000011;//SLL      
        20'b0110011010xxxxxxxxxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00100000011;//SLT
        20'b0110011011xxxxxxxxxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00110000011;//SLTU       
        20'b0110011100xxxxxxxxxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b01000000011;//XOR       
        20'b01100111010000000xxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b01010000011;//SRL       
        20'b01100111010100000xxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b11010000011;//SRA        
        20'b01100111100000000xxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b01100000011;//OR
        20'b01100111110000000xxx:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b01110000011;//AND
        default:{alu_fun,alu_srcA,alu_srcB,pcSource,rf_wr_sel}=11'b00000000000;
    endcase
endmodule




//moduleCU_Decoder(
//inputbr_eq,br_lt,br_ltu,
//input[6:0]ir0,[2:0]ir1,[6:0]ir2,
//outputlogic[3:0]alu_fun,alu_srcA,[1:0]alu_srcB,[1:0]pcSource,[3:0]rf_wr_sel
//);
//always_combbegin
//case(ir0)
//7'b0110111:begin//lui
//alu_fun=4'b1001;
//alu_srcA=1;
//alu_srcB=3;
//pcSource=0;
//rf_wr_sel=3;
//end
//7'b0010111:begin//auipc
//alu_srcA=1;
//alu_srcB=3;
//pcSource=0;
//rf_wr_sel=3;
//end
//7'b1101111:begin//jal
//pcSource=3;
//rf_wr_sel=0;
//end
//7'b1100111:begin
//case(ir1)
//3'b000:begin//jalr
//pcSource=3;
//rf_wr_sel=0;
//end
//endcase
//end
//7'b1100x11:begin
//case(ir1)
//3'b000:begin//beq
//pcSource=3;
//rf_wr_sel=0;
//end
//3'b001:begin//bne
//pcSource=3;
//rf_wr_sel=0;
//end
//3'b100:begin//blt
//pcSource=3;
//rf_wr_sel=0;
//end
//3'b101:begin//bge
//pcSource=3;
//rf_wr_sel=0;
//end
//3'b110:begin//bltu
//pcSource=3;
//rf_wr_sel=0;
//end
//3'b111:begin//bltu
//pcSource=3;
//rf_wr_sel=0;
//end
//endcase
//end

//endcase
//end
//endmodule
