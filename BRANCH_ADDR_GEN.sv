`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/08/2024 06:32:09 PM
// Design Name: 
// Module Name: BRANCH_ADDR_GEN
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


module BRANCH_ADDR_GEN(
    input logic [31:0] PC,
    input logic [31:0] JType,
    input logic [31:0] BType,
    input logic [31:0] IType,
    input logic [31:0] rs1,
    
    output logic [31:0] jal,
    output logic [31:0] branch,
    output logic [31:0] jalr
    );
    
    assign branch = PC + BType;
    assign jal = PC + JType;
    assign jalr = rs1 + IType;

endmodule
