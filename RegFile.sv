`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/23/2024 04:09:31 PM
// Design Name: 
// Module Name: RegFile
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


module RegFile(
    
    input logic RF_WE,
    input logic [4:0] adr1,
    input logic [4:0] adr2,
    input logic [4:0] w_adr,
    input logic [31:0] w_data,
    input logic CLK,
    
    output logic [31:0] rs1,
    output logic [31:0] rs2 
    );
    
    logic [31:0] RAM [0:31];                    //Create RAM
    
    initial begin
        int i;
        for (i=0; i<32; i=i+1) begin
            RAM[i] = 0;
        end
    end
    
    
    always_ff @ (negedge CLK) begin             //Write
    
        if ((RF_WE == 1) && (w_adr != 0))
            RAM[w_adr] <= w_data;
           
        else
            RAM[w_adr] <= RAM[w_adr];
            
    end
    
    

    assign rs1 = RAM[adr1];
    assign rs2 = RAM[adr2];
    
    
    
    
endmodule
