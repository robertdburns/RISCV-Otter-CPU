`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/08/2024 06:31:31 PM
// Design Name: 
// Module Name: BRANCH_COND_GEN
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


module BRANCH_COND_GEN(

    input logic [31:0] rs1,
    input logic [31:0] rs2,
    
    output logic br_eq,
    output logic br_lt,
    output logic br_ltu
    );
    
    always_comb begin
    
    if (rs1 == rs2) 
        br_eq = 1;  
    else
        br_eq = 0;
        
        
    if ($signed(rs1) < $signed(rs2))
        br_lt = 1;
    else
        br_lt = 0;
        
        
    if (rs1 < rs2)
        br_ltu = 1;
    else 
        br_ltu = 0;
    
    
    end
endmodule
