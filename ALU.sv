`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/30/2024 06:44:20 PM
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


module ALU(
    input logic [31:0] ALU_srcA,
    input logic [31:0] ALU_srcB,
    input logic [3:0] ALU_FUN,
    
    output logic [31:0] result
    );
    
    always_comb begin
        
        case (ALU_FUN)
            4'b0000: result = ($signed(ALU_srcA) + $signed(ALU_srcB));                  //ADD
            
            4'b1000: result = $signed(ALU_srcA) - $signed(ALU_srcB);                    //SUB
            
            4'b0110: result = ALU_srcA | ALU_srcB;                                     //OR
            
            4'b0111: result = ALU_srcA & ALU_srcB;                                      //AND
            
            4'b0100: result = ALU_srcA ^ ALU_srcB;                                      //XOR
            
            4'b0101: result = ALU_srcA >> ALU_srcB[4:0];                                //SRL
            
            4'b0001: result = ALU_srcA << ALU_srcB[4:0];                                //SLL
            
            4'b1101: result = $signed(ALU_srcA) >>> $signed(ALU_srcB[4:0]);                               //SRA
            
            4'b0010: if ($signed(ALU_srcA) < $signed(ALU_srcB))                             //SLT
                        result = 1;
                     else
                        result = 0;
            
            4'b0011: if (ALU_srcA < ALU_srcB)                                               //SLTU
                        result = 1;
                     else
                        result = 0;
                        
            4'b1001: result = ALU_srcA;                                             //LUI-COPY
            
            default: result = 32'hDEADDEAD;                                     //Default
            
        endcase
            
    end
    
endmodule
