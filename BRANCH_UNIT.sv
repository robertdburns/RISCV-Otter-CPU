`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/21/2024 05:26:24 PM
// Design Name: 
// Module Name: BRANCH_UNIT
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


module BRANCH_UNIT(
    input logic [31:0] rs1,
    input logic [31:0] rs2,
    input logic [31:0] ir,
    
    output logic [1:0]PC_SEL
    );
    
    logic br_eq;
    logic br_lt;
    logic br_ltu;
    
    logic [2:0] func3;
    assign func3 = ir[14:12];
    
    logic [6:0] opcode;
    assign opcode = ir[6:0];

    assign br_eq = rs1 == rs2;
    assign br_lt = $signed(rs1) < $signed(rs2);
    assign br_ltu = rs1 < rs2;

//    always_comb begin
//        if (rs1 == rs2) br_eq = 1;  
//        else br_eq = 0;
        
//        if ($signed(rs1) < $signed(rs2)) br_lt = 1;
//        else br_lt = 0;
        
//        if (rs1 < rs2) br_ltu = 1;
//        else  br_ltu = 0;
//    end
    
    
        always_comb begin
            if (opcode == 7'b1100011) begin                   // BEQ, BGE, BGEU, BLT, BLTU, BNE, ( PSEUDO: BEQZ, BGEZ, BGT, BGTU, BGTZ, BLE, BLEU, BLEZ, BLTZ, BNEZ )
                PC_SEL = 2'b00;
                // DEFAULTS FOR ALL B-TYPES

                case (func3)
                    3'b000: begin 
                        if (br_eq) PC_SEL = 2'b10;           // BEQ
                        else PC_SEL = 2'b00; // this is what causes it to break
                    end
                        
                    3'b101: begin 
                        if (!br_lt) PC_SEL = 2'b10;  // BGE
                        else PC_SEL = 2'b00;
                    end
                                                
                    3'b111: begin 
                        if (!br_ltu) PC_SEL = 2'b10; // BGEU
                        else PC_SEL = 2'b00;
                    end
                        
                    3'b100: begin 
                        if (br_lt) PC_SEL = 2'b10;           // BLT
                        else PC_SEL = 2'b00;
                    end
                                                
                    3'b110: begin 
                        if (br_ltu) PC_SEL = 2'b10;          // BLTU
                        else PC_SEL = 2'b00;
                    end
                        
                    3'b001: begin 
                        if (!br_eq) PC_SEL = 2'b10;      // BNE
                        else PC_SEL = 2'b00;
                    end
                               
                    default: begin 
                        PC_SEL = 'b0;
                    end
                        
                    endcase 
               
            end
            else if (opcode == 7'b1101111) PC_SEL = 2'b11;       // JAL
                                
            else if (opcode == 7'b1100111) PC_SEL = 2'b01;       // JALR
            
            else PC_SEL = 2'b00;
       end
                
endmodule
