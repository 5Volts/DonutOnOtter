`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.02.2021 13:37:26
// Design Name: 
// Module Name: CU_FSM
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


module CU_FSM(
    input clk,
    input INT_,
    input RST,                // reset
    input [6:0] ir,           // opcode
    output logic pcWrite,     // pcWrite to control pc counter
    output logic regWrite,    // used for enabling the write from the mux 
    output logic memWrite,    // used for storing memory (SW command)
    output logic memRead1,    // read instruction for a specific count
    output logic memRead2     // read a specific address of a value that you    want to load
    );

// Fetch 00 Execute 01 Writeback 10
    logic [1:0] state;     
    logic [1:0] next;

    always_ff @(posedge clk) begin
        if(RST) begin
            state <= 2'b00;
        end
        else state <= next;
    end
    always_comb begin
        pcWrite = 0;
        regWrite = 0;
        memWrite = 0;
        memRead1 = 0;
        memRead2 = 0;

        case(state)
//            default next = 2'b00;
            2'b00: begin
                pcWrite = 1'b0;  // increment counter
                memRead1 = 1'b1; // read instruction
                next = 2'b01;   // go to the execute state     
            end
            2'b01: begin  //decode + execute
                if (ir == 7'b0100011) begin // AUIPC
                    memWrite = 1'b1;
                    pcWrite = 1'b1;
                    next = 2'b00;
                end
                else if (ir == 7'b0000011) begin // Itype (load)
                    pcWrite = 1'b0;
                    memRead2 = 1'b1; // we are loading from an address  
                    next = 2'b10;
                end
                else if (ir == 7'b1100011) begin // Stype              
                    pcWrite = 1'b1;
                    next = 2'b00;  
                end
                else begin
                    pcWrite = 1'b1;
                    regWrite = 1'b1;
                    memRead1 = 1'b0;
                    next = 2'b00;
                end
            end
            2'b10: begin
                pcWrite = 1'b1;
                memRead2 = 1'b1;
                regWrite = 1'b1;
                next = 2'b00;
            end
            default: begin
                next = 2'b00;
            end
        endcase
     end
endmodule