`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/30/2024 06:45:28 PM
// Design Name: 
// Module Name: IMMED_GEN
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


module IMMED_GEN(

    input logic [31:7] ir,
    
    output logic [31:0] UType,
    output logic [31:0] IType,
    output logic [31:0] SType,
    output logic [31:0] JType,
    output logic [31:0] BType
    );
    
    assign UType = { {ir[31:12]}, {12{1'b0}} };                                             //each type is a combination of 
    assign IType = { {21{ir[31]}}, {ir[30:20]} };                                           //different bits of the input
    assign SType = { {21{ir[31]}}, {ir[30:25]}, {ir[11:7]}} ;                               //all are created and output
    assign JType = { {20{ir[31]}}, {ir[19:12]}, {{ir[20]}}, {ir[30:21]}, 1'b0 };
    assign BType = { {20{ir[31]}}, {2{ir[7]}}, {ir[30:25]}, {ir[11:8]}, 1'b0 };
    
    
endmodule
