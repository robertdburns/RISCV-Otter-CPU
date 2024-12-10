`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2024 02:23:42 PM
// Design Name: 
// Module Name: CU_DCDR
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


module CU_DCDR(

    input logic [6:0] OPCode,
    input logic [2:0] funct3,
    input logic IR30,
    input logic int_taken,
    input logic br_eq,
    input logic br_lt,
    input logic br_ltu,
    
    output logic [3:0] ALU_FUN,
    output logic [1:0] srcA_SEL,
    output logic [2:0] srcB_SEL,
    output logic [2:0] PC_SEL,
    output logic [1:0] RF_SEL
    
    
    );
    
    // initalize outputs to 0
    
    always_comb begin
    
    // SET DEFAULT VALUES
        ALU_FUN = 0;
        srcA_SEL = 0;
        srcB_SEL = 0;
        PC_SEL = 0;
        RF_SEL = 0;
        
        

        
        case (OPCode)
           
// ----------------------------------------------------------------------- R-TYPE -----------------------------------------------------------------------           
            7'b0110011:                    // ADD, AND, OR, SLL, SLT, SLU, SRA, SUB, XOR, SLTU, SRL, ( PSEUDO: NEG, SQTZ, SLTZ, SNEZ )
            
                // DEFAULTS FOR ALL R-TYPES
                begin
                RF_SEL = 2'b11;
                srcA_SEL = 0;
                srcB_SEL = 0;
                PC_SEL = 0;
                
                        case (funct3)
                        
                            3'b000:                 // ADD AND SUB
                                begin
                                // ALL DEFAULTS
                                case (IR30)
                                    0:                  // ADD
                                        ALU_FUN = 4'b0000;
                                    
                                    1:
                                        ALU_FUN = 4'b1000;
                                    
                                    default:
                                        begin
                                        end
                                    
                                    endcase
                                    
                                end
                                
                            3'b111:                 // AND
                                 begin
                                // ALL DEFAULTS
                                ALU_FUN = 4'b0111;
                                end
                                
                            3'b110:                 // OR
                                begin
                                // ALL DEFAULTS
                                ALU_FUN = 4'b0110;
                                end
                                
                            3'b001:                 // SLL
                                begin
                                // ALL DEFAULTS
                                ALU_FUN = 4'b0001;
                                end
                        
                            3'b010:                 // SLT
                                begin
                                // ALL DEFAULTS
                                ALU_FUN = 4'b0010;
                                end
                                
                            3'b011:                 // SLTU
                                begin
                                // ALL DEFAULTS
                                ALU_FUN = 4'b0011;
                                end
                                
                            3'b101:                 // SRA AND SRL
                                begin
                                // ALL DEFAULTS
                                case (IR30)
                                    0:                  // SRL
                                        begin
                                        ALU_FUN = 4'b0101;
                                        end
                                        
                                    1:                  // SRA
                                        begin
                                        ALU_FUN = 4'b1101;
                                        end
                                        
                                     default:
                                        begin
                                        end
                                    
                                    endcase
                                end
 
                                                            
                            3'b100:                 // XOR
                                begin
                                // ALL DEFAULTS
                                ALU_FUN = 4'b0100;
                                end
                                
                            default:
                                begin
                                end
                                
                            endcase
                end
            
// ----------------------------------------------------------------------- I-TYPE -----------------------------------------------------------------------                       
            7'b0010011:                    // ADDI, ANDI, ORI, SLLI, SLTI, SLTIU, SRAI, SRLI, XORI, ( PSEUDO: LA, LI, MV, NOP, NOT, SEQZ )
                
                // DEFAULTS FOR ALL I-TYPES
                begin
                RF_SEL = 2'b11;
                srcA_SEL = 2'b0;
                srcB_SEL = 3'b1; 
                
                case (funct3)
                
                    3'b000:                 // ADD
                        begin
                        // ALL DEFAULTS
                        ALU_FUN = 4'b0000;
                        end
                        
                    3'b111:                 // AND
                         begin
                        // ALL DEFAULTS
                        ALU_FUN = 4'b0111;
                        end
                        
                    3'b110:                 // OR
                        begin
                        // ALL DEFAULTS
                        ALU_FUN = 4'b0110;
                        end
                        
                    3'b001:                 // SLL
                        begin
                        // ALL DEFAULTS
                        ALU_FUN = 4'b0001;
                        end
                
                    3'b010:                 // SLT
                        begin
                        // ALL DEFAULTS
                        ALU_FUN = 4'b0010;
                        end
                        
                    3'b011:                 // SLTU
                        begin
                        // ALL DEFAULTS
                        ALU_FUN = 4'b0011;
                        end
                        
                    3'b101:                 // SRA AND SRL
                        begin
                        // ALL DEFAULTS
                        case (IR30)
                            0:                  // SRL
                                begin
                                ALU_FUN = 4'b0101;
                                end
                                
                            1:                  // SRA
                                begin
                                ALU_FUN = 4'b1101;
                                end
                                
                             default:
                                begin
                                end
                            
                            endcase
                        end
                                                    
                    3'b100:                 // XOR
                        begin
                        // ALL DEFAULTS
                        ALU_FUN = 4'b0100;
                        end
                        
                    default:
                        begin
                        end
                        
                    endcase
                end
            
            
// ----------------------------------------------------------------------- S-TYPE -----------------------------------------------------------------------                 
            7'b0100011:                    // SB, SH, SW
                
                // DEFAULTS FOR ALL S-TYPES
                begin
                ALU_FUN = 4'b0000;
                srcA_SEL = 2'b0;
                srcB_SEL = 3'b010;
                RF_SEL = 2'b0;
                PC_SEL = 3'b0;
                
                
                case (funct3)
                    3'b000:                 // SB
                        begin
                        // ALL DEFAULTS
                        end
                    
                    3'b001:                 // SH
                        begin
                        // ALL DEFAULTS
                        end
                    
                    3'b010:                 // SW
                        begin
                        // ALL DEFAULTS
                        end
                
                    default:
                        begin
                        end

                endcase
                end
            
// ----------------------------------------------------------------------- B-TYPE -----------------------------------------------------------------------                 
            
            7'b1100011:                    // BEQ, BGE, BGEU, BLT, BLTU, BNE, ( PSEUDO: BEQZ, BGEZ, BGT, BGTU, BGTZ, BLE, BLEU, BLEZ, BLTZ, BNEZ )
            
                // DEFAULTS FOR ALL B-TYPES
                begin
                ALU_FUN = 4'b0;
                srcA_SEL = 2'b0;
                srcB_SEL = 3'b0;
                RF_SEL = 2'b0;

                case (funct3)
                    3'b000:                 // BEQ
                        begin
                        if (br_eq)
                            PC_SEL = 3'b010;
                        else
                            begin
                            end
                        end
                    
                    3'b101:                 // BGE
                        begin
                        if (br_eq | !br_lt)
                            PC_SEL = 3'b010;
                        else
                            begin
                            end
                        end
                        
                    3'b111:                 // BGEU
                        begin
                        if (br_eq | !br_ltu)
                            PC_SEL = 3'b010;
                        else
                            begin
                            end
                        end
                        
                    3'b100:                 // BLT
                        begin
                        if (br_lt)
                            PC_SEL = 3'b010;
                        else
                            begin
                            end
                        end
                        
                    3'b110:                 // BLTU
                        begin
                        if (br_ltu)
                            PC_SEL = 3'b010;
                        else
                            begin
                            end
                        end
                        
                    3'b001:                 // BNE
                        begin
                        if (br_eq == 0)
                            PC_SEL = 3'b010;
                        else
                            PC_SEL = 3'b000;
                        end
                    
                    default:
                        begin
                        end
                        
                    endcase 
                end
            
// ----------------------------------------------------------------------- LUI -----------------------------------------------------------------------                   
            7'b0110111:                    // LUI
                begin
                srcA_SEL = 1;
                srcB_SEL = 0;
                ALU_FUN = 4'b1001;
                RF_SEL = 4'b11;
                end
            
// ----------------------------------------------------------------------- AUIPC -----------------------------------------------------------------------                   
            7'b0010111:                    // AUIPC, ( PSEUDO: LA )
                begin
                ALU_FUN = 4'b0000;
                srcA_SEL = 2'b1;
                srcB_SEL = 3'b011;
                RF_SEL = 2'b11;
                PC_SEL = 3'b0;
                end
            
            
// ----------------------------------------------------------------------- J-TYPE -----------------------------------------------------------------------       
            7'b1101111:                    // JAL
                begin
                
                ALU_FUN = 0;
                srcA_SEL = 0;
                srcB_SEL = 0;
                PC_SEL = 3'b011;
                RF_SEL = 0;

                end
                
            7'b1100111:                     // JALR
                begin
                ALU_FUN = 4'b0000;
                srcA_SEL = 0;
                srcB_SEL = 0;
                PC_SEL = 3'b001;
                RF_SEL = 2'b0;
                end
            
            
// ----------------------------------------------------------------------- CONTROL & STATUS -----------------------------------------------------------------------                   
            7'b1110011:                    // CSRRC, CSRRS, CSRRW, MRET ( PSEUDO: CSRW )
                begin
                case (funct3)
                
                    3'b000:                 // MRET
                        begin
                        PC_SEL = 3'b101;
                        srcA_SEL = 0;
                        ALU_FUN = 4'b1001;
                        end
                
                    3'b001:                 // CSRRW
                        begin
                        PC_SEL = 3'b0;
                        ALU_FUN = 4'b1001;
                        srcA_SEL = 2'b0;
                        RF_SEL = 2'b01;
                        end
                    
                    3'b010:                 // CSRRS
                        begin
                        PC_SEL = 3'b0;
                        ALU_FUN = 4'b0110;
                        srcA_SEL = 2'b0;
                        srcB_SEL = 3'b100;
                        RF_SEL = 2'b01;
                        end
                    
                    3'b011:                 // CSRRC
                        begin
                        srcA_SEL = 2'b10;
                        srcB_SEL = 3'b100;
                        ALU_FUN = 4'b0111;
                        PC_SEL = 3'b0;
                        RF_SEL = 2'b01;
                        end
                    
                    default:
                        begin
                        ALU_FUN = 0;
                        srcA_SEL = 0;
                        srcB_SEL = 0;
                        PC_SEL = 0;
                        RF_SEL = 0;
                        end
                endcase
                end
            
            
// ----------------------------------------------------------------------- LOAD -----------------------------------------------------------------------                   
            7'b0000011:                    // LB, LBU, LH, LHU, LW
            
                // DEFAULTS FOR ALL LOADS
                begin
                ALU_FUN = 4'b0000;
                srcA_SEL = 2'b0;
                srcB_SEL = 3'b001;
                RF_SEL = 2'b10;
                case (funct3)
                
                    3'b000:                 // LB
                        begin
                        end
                        
                    3'b100:                 // LBU
                        begin
                        end
                        
                    3'b001:                 // LH
                        begin
                        end
                        
                    3'b101:                 // LHU
                        begin
                        end
                    
                    3'b010:                 // LW
                        begin
                        end
                        
                    default:
                        begin
                        end
                        
                    endcase
 
    end
            default:
                begin
                ALU_FUN = 0;
                srcA_SEL = 0;
                srcB_SEL = 0;
                PC_SEL = 0;
                RF_SEL = 0;
                end
    
    endcase
    
    
        if (int_taken == 1) begin
        PC_SEL = 3'b100;
        end
    
    end
   
    

    

endmodule
