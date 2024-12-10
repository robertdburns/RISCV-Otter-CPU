`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/16/2024 12:20:31 PM
// Design Name: 
// Module Name: PC
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


module PC(
    input logic PC_RST,
    input logic PC_WE,
    input logic [31:0] PC_DIN,
    input logic CLK,
    output logic [31:0] PC_COUNT
    );
    
    always_ff @ (posedge CLK) begin         
        if (PC_RST == 1)                            //if we enable reset, set the output to 0
            PC_COUNT <= 0;  
    
        else if (PC_WE == 1)                        //if the reset is not enabled we set the output to
            begin                                   //what the mux provides
            PC_COUNT <= PC_DIN;
            end
                    
    end

endmodule
