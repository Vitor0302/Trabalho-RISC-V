// core/stage_id.v
module stage_id (
    // Inputs
    input         clock,
    input         reset,
    input  [31:0] if_id_instruction,
    input         mem_wb_regwrite,
    input  [4:0]  mem_wb_rd,
    input  [31:0] wb_write_data,

    // Outputs
    output [4:0]  id_rs1,
    output [4:0]  id_rs2,
    output [31:0] id_read_data_1,
    output [31:0] id_read_data_2,
    output [31:0] id_immediate,
    // Sinais de controle para o próximo estágio
    output        id_regwrite,
    output        id_alusrc,
    output        id_memtoreg,
    output        id_memread,
    output        id_memwrite,
    output        id_branch,
    output [1:0]  id_aluop,
    // Campos da instrução para o próximo estágio
    output [4:0]  id_rd,
    output [2:0]  id_funct3,
    output [6:0]  id_funct7
);

    wire [6:0] opcode = if_id_instruction[6:0];
    assign id_rs1    = if_id_instruction[19:15];
    assign id_rs2    = if_id_instruction[24:20];
    assign id_rd     = if_id_instruction[11:7];
    assign id_funct7 = if_id_instruction[31:25];
    assign id_funct3 = if_id_instruction[14:12];

    Unidade_Controle_Principal u_main_control (
        .opcode(opcode),
        .RegWrite(id_regwrite), .ALUSrc(id_alusrc), .MemToReg(id_memtoreg),
        .MemRead(id_memread), .MemWrite(id_memwrite), .Branch(id_branch),
        .ALUOp(id_aluop)
    );

    REG_FILE u_regfile (
        .clock(clock), .reset(reset),
        .regwrite(mem_wb_regwrite),
        .read_reg_num1(id_rs1),
        .read_reg_num2(id_rs2),
        .write_reg(mem_wb_rd),
        .write_data(wb_write_data),
        .read_data1(id_read_data_1),
        .read_data2(id_read_data_2)
    );

    assign id_immediate = (opcode == 7'b0100011) ? {{20{if_id_instruction[31]}}, if_id_instruction[31:25], if_id_instruction[11:7]} :
                          (opcode == 7'b1100011) ? {{20{if_id_instruction[31]}}, if_id_instruction[7], if_id_instruction[30:25], if_id_instruction[11:8], 1'b0} :
                                                   {{20{if_id_instruction[31]}}, if_id_instruction[31:20]};

endmodule