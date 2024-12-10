`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:  J. Callenes
// 
// Create Date: 01/04/2019 04:32:12 PM
// Design Name: 
// Module Name: PIPELINED_OTTER_CPU
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
 
typedef enum logic [6:0] {
       LUI      = 7'b0110111,
       AUIPC    = 7'b0010111,
       JAL      = 7'b1101111,
       JALR     = 7'b1100111,
       BRANCH   = 7'b1100011,
       LOAD     = 7'b0000011,
       STORE    = 7'b0100011,
       OP_IMM   = 7'b0010011,
       OP       = 7'b0110011,
       SYSTEM   = 7'b1110011
} opcode_t;
 
typedef struct packed{
    opcode_t opcode;
//    logic [31:0] rs1;
//    logic [31:0] rs2;
    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [4:0] rd_addr;
    logic rs1_used;
    logic rs2_used;
    logic rd_used;
    logic [3:0] alu_fun;
    logic alu_srcA;
    logic [1:0] alu_srcB;
    logic memWrite;
    logic memRead2;
    logic regWrite;
    logic [1:0] rf_wr_sel;
    logic [2:0] mem_type;  //sign, size
    logic [31:0] pc;
    logic [31:0] pc_next;
    // logic [31:0] alu_result;
    logic [31:0] ir;
    
    logic [31:0] utype;
    logic [31:0] itype;
    logic [31:0] stype;
    logic [31:0] jtype;
    logic [31:0] btype;

} instr_t;

module OTTER_MCU(input CLK,
                input INTR,
                input RST,
                input [31:0] IOBUS_IN,
                
                output [31:0] IOBUS_OUT,
                output [31:0] IOBUS_ADDR,
                output logic IOBUS_WR 
);           
    logic [31:0] de_pc, pc;
    logic [31:0] JALR_PC;
    logic [31:0] BRANCH_PC;
    logic [31:0] JUMP_PC;
    logic [31:0] ALU_srcA;
    logic [31:0] ALU_srcB;
    logic [31:0] IR;
    logic PCWE;
    logic MEMRE;
    logic [1:0] PC_SEL;
    logic br_lt,br_eq,br_ltu;
    logic [31:0] MEMData;
    logic [31:0] DEC_rs1, DEC_rs2;
   // logic [1:0] PC_SEL;
    
    instr_t DEC_inst;
    instr_t EX_inst;
    instr_t MEM_inst;
    instr_t WB_inst;
    
    
              
//==== Instruction Fetch =================================================================================================================

     logic STALL;
     logic FLUSH;
     logic HOLD_FLUSH;
     
     
     always_ff @(posedge CLK) begin
        HOLD_FLUSH <= FLUSH;
        if (!STALL)
            de_pc <= pc;
          
     end
     
     assign pcWrite = !STALL; 	// Hardwired high, assuming now hazards
     assign memRead1 = !STALL;	// Fetch new instruction every cycle
     logic [31:0] PC_DIN;           // Wire from PC MUX to PC
     
     logic [31:0] PC_PLUS4;
     assign PC_PLUS4 = pc + 4;  
     
     always_comb begin                          // PC MUX
        case (PC_SEL)                           //Basic mux function which changes the output
            2'b00: PC_DIN = PC_PLUS4;          //depending on the value of PC_SEL
            2'b01: PC_DIN = JALR_PC;
            2'b10: PC_DIN = BRANCH_PC;
            2'b11: PC_DIN = JUMP_PC;
//            3'b100: PC_DIN = MTVEC;
//            3'b101: PC_DIN = MEPC;
            default PC_DIN = 32'hDEADDEAD;      //default case for debugging later   
        endcase
    end
    
    
    PC PC(
        .PC_RST(RST), 
        .PC_WE(pcWrite), 
        .PC_DIN(PC_DIN),
        .CLK(CLK),
    
        .PC_COUNT(pc)
    );
        
   
     
//==== Instruction Decode ================================================================================================================

    assign DEC_inst.ir = IR;
    
    logic [6:0] opcode;
    assign DEC_inst.opcode = opcode_t'(DEC_inst.ir[6:0]);
    assign DEC_inst.pc = de_pc;
    assign DEC_inst.rs1_addr=IR[19:15];
    assign DEC_inst.rs2_addr=IR[24:20];
    assign DEC_inst.rd_addr=IR[11:7];
    
    logic [1:0] fsel1;
    logic [1:0] fsel2;
    
   
    assign DEC_inst.rs1_used=   DEC_inst.rs1_addr != 0 
                                && DEC_inst.opcode != LUI
                                && DEC_inst.opcode != AUIPC
                                && DEC_inst.opcode != JAL;
                                
    assign DEC_inst.rs2_used=   DEC_inst.rs2_addr != 0 
                                && DEC_inst.opcode != LUI
                                && DEC_inst.opcode != AUIPC
                                && DEC_inst.opcode != JAL
                                && DEC_inst.opcode != LOAD
                                && DEC_inst.opcode != OP_IMM
                                && DEC_inst.opcode != JALR;
                                
     assign DEC_inst.rd_used =  DEC_inst.rd_addr != 0
                                && DEC_inst.opcode != BRANCH
                                && DEC_inst.opcode != STORE;
                                

     logic srcA_SEL;
     logic [1:0] srcB_SEL;
     
    FullDecoder FullDecoder (
        .OPCode( DEC_inst.ir[6:0] ),
        .funct3( DEC_inst.ir[14:12] ),
        .IR30( DEC_inst.ir[30] ),
//        .int_taken ( 1'b0 ),
        .br_eq( br_eq ),
        .br_lt( br_lt ),
        .br_ltu( br_ltu),
        
        .ALU_FUN( DEC_inst.alu_fun ),
        .srcA_SEL ( srcA_SEL ),                                                                                             //
        .srcB_SEL ( srcB_SEL ),                                                                                             // 
        .RF_SEL ( DEC_inst.rf_wr_sel ),
        .RF_WE ( DEC_inst.regWrite ),
        .memWE2 ( DEC_inst.memWrite ),
        .memRDEN2 ( DEC_inst.memRead2 )
    );

     
     
    IMMED_GEN IMMED_GEN (
        .ir ( DEC_inst.ir[31:7] ),
    
        .UType(DEC_inst.utype),
        .IType(DEC_inst.itype),
        .SType(DEC_inst.stype),
        .JType(DEC_inst.jtype),
        .BType(DEC_inst.btype)
    );
    
    
    logic [1:0] DEC_fsel1;
    logic [1:0] DEC_fsel2;
    logic [6:0] ex_opcode;
    assign ex_opcode = EX_inst.ir[6:0];
    
    HDU HDU(
        .opcode(ex_opcode), // EXECUTE OPCODE
        .DEC_rs1(DEC_inst.rs1_addr),
        .DEC_rs2(DEC_inst.rs2_addr),
        .EX_rs1(EX_inst.rs1_addr),
        .EX_rs2(EX_inst.rs2_addr),
        .EX_rd(EX_inst.rd_addr),
        .MEM_rd(MEM_inst.rd_addr),
        .WB_rd(WB_inst.rd_addr),
        .PC_src(PC_SEL),
        .MEM_REGWE(MEM_inst.regWrite),
        .WB_REGWE(WB_inst.regWrite),
        .DEC_rs1_used(DEC_inst.rs1_used),
        .DEC_rs2_used(DEC_inst.rs2_used),
        .EX_rs1_used(EX_inst.rs1_used),
        .EX_rs2_used(EX_inst.rs2_used),
        
        .fsel1(fsel1),
        .fsel2(fsel2),
        .STALL(STALL),
        .FLUSH(FLUSH));

    
    logic DEC_srcA_SEL;
    assign DEC_srcA_SEL = srcA_SEL;
    logic [1:0] DEC_srcB_SEL;
    assign DEC_srcB_SEL = srcB_SEL;

     
    
	
	
//==== Execute =================================================================================================================
      logic [31:0] EX_rs1, EX_rs2;
      
      logic EX_srcA_SEL;
      logic [1:0] EX_srcB_SEL;

      logic [31:0] f_srcA;
      logic [31:0] f_srcB;
      
      logic [31:0] EX_alu_result;
      logic [31:0] MEM_alu_result;
      logic [31:0] WB_alu_result;
      
      logic [31:0] w_data;
      
     
     always_ff @(posedge CLK) begin
        EX_inst <= DEC_inst;
        if (HOLD_FLUSH || FLUSH || STALL) begin
            EX_inst.regWrite <= 0;
            EX_inst.memWrite <= 0;
            EX_inst.ir <= 0;
        end
        EX_srcA_SEL <= DEC_srcA_SEL;
        EX_srcB_SEL <= DEC_srcB_SEL;
//        EX_fsel1 <= DEC_fsel1;
//        EX_fsel2 <= DEC_fsel2;
        
        EX_rs1 <= DEC_rs1;
        EX_rs2 <= DEC_rs2;
     end
     
     // Creates a RISC-V ALU
     
             // Forward Mux 1
    always_comb begin
        case (fsel1)
            2'b00: f_srcA = EX_rs1;
            2'b01: f_srcA = MEM_alu_result;
            2'b10: f_srcA = w_data;
            default:
                f_srcA = 32'hDEADDEAD;
        endcase
    end
        
        // Forward Mux 2
    always_comb begin
        case(fsel2)
            2'b00: f_srcB = EX_rs2;
            2'b01: f_srcB = MEM_alu_result;
            2'b10: f_srcB = w_data;
            default:
                f_srcB = 32'hDEADDEAD;
        endcase
    end
    
    // ALU SOURCE A MUX
           
    always_comb begin
        case (EX_srcA_SEL)
            1'b0: ALU_srcA = f_srcA;
            1'b1: ALU_srcA = EX_inst.utype;
            default:
                ALU_srcA = 32'hDEADDEAD;
        endcase
    end

        // ALU SOURCE B MUX
        
    always_comb begin
        case (EX_srcB_SEL)
            2'b00: ALU_srcB = f_srcB;
            2'b01: ALU_srcB = EX_inst.itype;
            2'b10: ALU_srcB = EX_inst.stype;
            2'b11: ALU_srcB = EX_inst.pc;
            default:
                ALU_srcB = 32'hDEADDEAD;
        endcase
    end
    
    
    
    ALU ALU (
        .ALU_srcA(ALU_srcA),
        .ALU_srcB(ALU_srcB),
        .ALU_FUN(EX_inst.alu_fun),
    
        .result(EX_alu_result)
    );
    
    
    
    BRANCH_ADDR_GEN BRANCH_ADDR_GEN (
        .PC(EX_inst.pc),
        .JType(EX_inst.jtype),  
        .BType(EX_inst.btype),
        .IType(EX_inst.itype),
        .rs1(f_srcA),
    
        .jal(JUMP_PC),
        .branch(BRANCH_PC),
        .jalr(JALR_PC)
    );
    
    
    BRANCH_UNIT BRANCH_UNIT (
        .rs1(f_srcA),
        .rs2(f_srcB),
        .ir(EX_inst.ir),
        
        .PC_SEL(PC_SEL)
        
    );    
    
     




//==== Memory =================================================================================================================
     
     
    // assign IOBUS_ADDR = ex_mem_aluRes;
    // assign IOBUS_OUT = ex_mem_rs2;
    logic [31:0] MEM_rs1, MEM_rs2;
    logic [31:0] MEMDIN2;
    logic [4:0] HOLD_rd_addr;
    logic [31:0] HOLD_w_data;
    
    always_ff @(posedge CLK) begin
        MEM_inst <= EX_inst;
        MEM_alu_result <= EX_alu_result;
        
        MEM_rs1 <= f_srcA;
        MEM_rs2 <= f_srcB;
     end
    
    always_comb begin // may not need to exist
        if (MEM_inst.opcode == STORE) begin
            MEMDIN2 = w_data;
            if (HOLD_rd_addr == MEM_inst.rs2_addr) MEMDIN2 = HOLD_w_data;
        end
        else MEMDIN2 = MEM_rs2;
    end
    
    logic ERR;
    logic mem_sign;
    logic [1:0] mem_size;
    assign mem_sign = MEM_inst.ir[14];
    assign mem_size = MEM_inst.ir[13:12];
    OTTER_mem_byte Memory (
        .MEM_CLK(CLK),
        .MEM_READ1(memRead1),
        .MEM_READ2(MEM_inst.memRead2),
        .MEM_WRITE2(MEM_inst.memWrite),
        .MEM_ADDR1(pc),
        .MEM_ADDR2(MEM_alu_result),
        .MEM_DIN2(MEM_rs2), // might need to be MEM_rs2
        .MEM_SIZE( mem_size ),
        .MEM_SIGN( mem_sign ),
        .IO_IN(IOBUS_IN),
        .ERR(ERR),
    
        .IO_WR(IOBUS_WR),
        .MEM_DOUT1(IR),
        .MEM_DOUT2(MEMData)
    );
    
    
    
 
 
 
     
//==== Write Back =================================================================================================================
     
     logic [31:0] CSR_REG = 32'b0;
     
     always_ff @(posedge CLK) begin
        WB_inst <= MEM_inst;
        WB_alu_result <= MEM_alu_result;
        HOLD_w_data <= w_data;
     end
     
    // RF MUX
    always_comb begin
        case (WB_inst.rf_wr_sel) 
            2'b00:
                w_data = WB_inst.pc+4;
            2'b01:
                w_data = CSR_REG;
            2'b10:
                w_data = MEMData;
            2'b11:
                w_data = WB_alu_result;
            default:
                w_data = 32'hDEADDEAD;
        endcase
    end

    RegFile RegFile (
        .RF_WE (WB_inst.regWrite),
        .adr1 ( DEC_inst.rs1_addr ),
        .adr2 ( DEC_inst.rs2_addr ),
        .w_adr ( WB_inst.rd_addr ),
        .w_data (w_data),
        .CLK (CLK),
   
        .rs1 (DEC_rs1),
        .rs2 (DEC_rs2)
    );
 
 
    always_ff @ (posedge CLK) HOLD_rd_addr <= WB_inst.rd_addr;
       
            
endmodule