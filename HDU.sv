`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/05/2024 02:47:17 PM
// Design Name: 
// Module Name: HDU
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


module HDU(
    input logic [6:0] opcode,
    input logic [4:0] DEC_rs1,
    input logic [4:0] DEC_rs2,
    input logic [4:0] EX_rs1,
    input logic [4:0] EX_rs2,
    input logic [4:0] EX_rd,
    input logic [4:0] MEM_rd,
    input logic [4:0] WB_rd,
    input logic [1:0] PC_src,
    input logic MEM_REGWE,
    input logic WB_REGWE,
    input logic DEC_rs1_used,
    input logic DEC_rs2_used,
    input logic EX_rs1_used,
    input logic EX_rs2_used,

    output logic [1:0] fsel1,
    output logic [1:0] fsel2,
    output logic STALL,
    output logic FLUSH
    );

    always_comb begin
        fsel1 = 2'b00;
        fsel2 = 2'b00;

        STALL = 1'b0;
        FLUSH = 1'b0;

        // Selects for forwarding muxes
        if (MEM_rd == EX_rs1 && EX_rs1_used && MEM_REGWE) begin
            fsel1 = 2'b01;
        end
        else if (WB_rd == EX_rs1 && EX_rs1_used && WB_REGWE) begin
            fsel1 = 2'b10;
        end
        else begin
            fsel1 = 2'b00;
        end
        
        
        if (MEM_rd == EX_rs2 && EX_rs2_used && MEM_REGWE) fsel2 = 2'b01;
        else if (WB_rd == EX_rs2 && EX_rs2_used && WB_REGWE) fsel2 = 2'b10;
        else fsel2 = 2'b00;

        // Load-use data hazard
        if ((opcode == 7'b0000011) && ((DEC_rs1 == EX_rd && DEC_rs1_used) || (DEC_rs2 == EX_rd && DEC_rs2_used))) begin
            STALL = 1'b1;
        end
        
        
        //((MEM_rd == EX_rs1) || (MEM_rd == EX_rs2))) STALL = 1'b1; 
        else begin
            STALL = 1'b0;
        end
        
//        if (STALL) begin
//            if (EX_rd == DEC_rs1) fsel1 = 2'b10;
//            else if (EX_rd == DEC_rs2) fsel2 = 2'b10;
//        end

        // Control hazards
        if (PC_src != 'b0) begin
            FLUSH = 'b1;
        end
        else begin
            FLUSH = 'b0;
        end
    end

endmodule