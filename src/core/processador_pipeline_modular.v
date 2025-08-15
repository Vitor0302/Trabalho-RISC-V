// core/processador_pipeline_modular.v
/*
Módulo Top-Level do Processador RISC-V com Pipeline Modularizado
Grupo 12: lh, sh, sub, or, andi, srl, beq
*/
module processador_pipeline_modular(
    input clock,
    input reset
);

    // --- Sinais de Conexão entre Estágios ---

    // IF -> IF/ID
    wire [31:0] w_if_instruction, w_if_pc;

    // IF/ID -> ID
    wire [31:0] w_if_id_instruction, w_if_id_pc;

    // ID -> ID/EX
    wire [31:0] w_id_read_data_1, w_id_read_data_2, w_id_immediate;
    wire [4:0]  w_id_rs1, w_id_rs2, w_id_rd;
    wire [2:0]  w_id_funct3;
    wire [6:0]  w_id_funct7;
    wire        w_id_regwrite, w_id_alusrc, w_id_memtoreg, w_id_memread, w_id_memwrite, w_id_branch;
    wire [1:0]  w_id_aluop;

    // ID/EX -> EX
    wire [31:0] w_id_ex_pc, w_id_ex_read_data_1, w_id_ex_read_data_2, w_id_ex_immediate;
    wire [4:0]  w_id_ex_rs1, w_id_ex_rs2, w_id_ex_rd;
    wire [2:0]  w_id_ex_funct3;
    wire [6:0]  w_id_ex_funct7;
    wire        w_id_ex_regwrite, w_id_ex_alusrc, w_id_ex_memtoreg, w_id_ex_memread, w_id_ex_memwrite, w_id_ex_branch;
    wire [1:0]  w_id_ex_aluop;

    // EX -> EX/MEM
    wire [31:0] w_ex_alu_result, w_ex_branch_target_addr, w_ex_write_data_mem;
    wire        w_ex_zero_flag;

    // EX/MEM -> MEM
    wire [31:0] w_ex_mem_alu_result, w_ex_mem_write_data_mem;
    wire [4:0]  w_ex_mem_rd;
    wire        w_ex_mem_zero_flag;
    wire        w_ex_mem_regwrite, w_ex_mem_memtoreg, w_ex_mem_memread, w_ex_mem_memwrite, w_ex_mem_branch;

    // MEM -> MEM/WB
    wire [31:0] w_mem_read_data;

    // MEM/WB -> WB
    wire [31:0] w_mem_wb_mem_read_data, w_mem_wb_alu_result;
    wire [4:0]  w_mem_wb_rd;
    wire        w_mem_wb_regwrite, w_mem_wb_memtoreg;
    
    // WB -> ID (Feedback)
    wire [31:0] w_wb_write_data_to_regfile;

    // --- Sinais de Controle de Hazard e Branch ---
    wire w_pc_stall, w_if_id_stall, w_id_ex_bubble;
    wire w_branch_taken;
    wire [1:0] w_forward_a, w_forward_b;


    // --- Lógica de Controle Global ---
    assign w_branch_taken = w_ex_mem_branch & w_ex_mem_zero_flag;

    Hazard_Detection_Unit u_hazard_detection (
        .IF_ID_rs1(w_id_rs1), .IF_ID_rs2(w_id_rs2),
        .ID_EX_MemRead(w_id_ex_memread), .ID_EX_rd(w_id_ex_rd),
        .PC_Stall(w_pc_stall),
        .IF_ID_Stall(w_if_id_stall),
        .ID_EX_Bubble(w_id_ex_bubble)
    );
    
    Forwarding_Unit u_forwarding (
        .EX_MEM_RegWrite(w_ex_mem_regwrite), .EX_MEM_rd(w_ex_mem_rd),
        .MEM_WB_RegWrite(w_mem_wb_regwrite), .MEM_WB_rd(w_mem_wb_rd),
        .ID_EX_rs1(w_id_ex_rs1), .ID_EX_rs2(w_id_ex_rs2),
        .ForwardA(w_forward_a), .ForwardB(w_forward_b)
    );

    // --- INSTÂNCIA DOS MÓDULOS ---

    // Estágio 1: IF
    stage_if u_stage_if (
        .clock(clock), .reset(reset),
        .pc_stall(w_pc_stall),
        .branch_taken(w_branch_taken),
        .branch_target_addr(w_ex_branch_target_addr),
        .instruction(w_if_instruction),
        .pc_current(w_if_pc)
    );

    // Registrador IF/ID
    reg_if_id u_reg_if_id (
        .clock(clock), .reset(reset),
        .if_id_stall(w_if_id_stall),
        .branch_taken(w_branch_taken),
        .in_instruction(w_if_instruction),
        .in_pc(w_if_pc),
        .out_instruction(w_if_id_instruction),
        .out_pc(w_if_id_pc)
    );
    
    // Estágio 2: ID
    stage_id u_stage_id (
        .clock(clock), .reset(reset),
        .if_id_instruction(w_if_id_instruction),
        .mem_wb_regwrite(w_mem_wb_regwrite),
        .mem_wb_rd(w_mem_wb_rd),
        .wb_write_data(w_wb_write_data_to_regfile),
        .id_rs1(w_id_rs1), .id_rs2(w_id_rs2),
        .id_read_data_1(w_id_read_data_1), .id_read_data_2(w_id_read_data_2),
        .id_immediate(w_id_immediate),
        .id_regwrite(w_id_regwrite), .id_alusrc(w_id_alusrc), .id_memtoreg(w_id_memtoreg),
        .id_memread(w_id_memread), .id_memwrite(w_id_memwrite), .id_branch(w_id_branch),
        .id_aluop(w_id_aluop),
        .id_rd(w_id_rd), .id_funct3(w_id_funct3), .id_funct7(w_id_funct7)
    );

    // Registrador ID/EX
    reg_id_ex u_reg_id_ex (
        .clock(clock), .reset(reset),
        .branch_taken(w_branch_taken),
        .id_ex_bubble(w_id_ex_bubble),
        .in_pc(w_if_id_pc), .in_read_data_1(w_id_read_data_1), .in_read_data_2(w_id_read_data_2),
        .in_immediate(w_id_immediate),
        .in_rs1(w_id_rs1), .in_rs2(w_id_rs2), .in_rd(w_id_rd),
        .in_funct3(w_id_funct3), .in_funct7(w_id_funct7),
        .in_regwrite(w_id_regwrite), .in_alusrc(w_id_alusrc), .in_memtoreg(w_id_memtoreg),
        .in_memread(w_id_memread), .in_memwrite(w_id_memwrite), .in_branch(w_id_branch),
        .in_aluop(w_id_aluop),
        .out_pc(w_id_ex_pc), .out_read_data_1(w_id_ex_read_data_1), .out_read_data_2(w_id_ex_read_data_2),
        .out_immediate(w_id_ex_immediate),
        .out_rs1(w_id_ex_rs1), .out_rs2(w_id_ex_rs2), .out_rd(w_id_ex_rd),
        .out_funct3(w_id_ex_funct3), .out_funct7(w_id_ex_funct7),
        .out_regwrite(w_id_ex_regwrite), .out_alusrc(w_id_ex_alusrc), .out_memtoreg(w_id_ex_memtoreg),
        .out_memread(w_id_ex_memread), .out_memwrite(w_id_ex_memwrite), .out_branch(w_id_ex_branch),
        .out_aluop(w_id_ex_aluop)
    );
    
    // Estágio 3: EX
    stage_ex u_stage_ex (
        .id_ex_pc(w_id_ex_pc), .id_ex_read_data_1(w_id_ex_read_data_1), .id_ex_read_data_2(w_id_ex_read_data_2),
        .id_ex_immediate(w_id_ex_immediate),
        .forward_a(w_forward_a), .forward_b(w_forward_b),
        .id_ex_alusrc(w_id_ex_alusrc), .id_ex_aluop(w_id_ex_aluop),
        .id_ex_funct7(w_id_ex_funct7), .id_ex_funct3(w_id_ex_funct3),
        .ex_mem_alu_result_fwd(w_ex_mem_alu_result),
        .wb_write_data_fwd(w_wb_write_data_to_regfile),
        .ex_alu_result(w_ex_alu_result), .ex_zero_flag(w_ex_zero_flag),
        .ex_branch_target_addr(w_ex_branch_target_addr),
        .ex_write_data_mem(w_ex_write_data_mem)
    );

    // Registrador EX/MEM
    reg_ex_mem u_reg_ex_mem (
        .clock(clock), .reset(reset),
        .in_alu_result(w_ex_alu_result), .in_write_data_mem(w_ex_write_data_mem),
        .in_rd(w_id_ex_rd), .in_zero_flag(w_ex_zero_flag),
        .in_regwrite(w_id_ex_regwrite), .in_memtoreg(w_id_ex_memtoreg),
        .in_memread(w_id_ex_memread), .in_memwrite(w_id_ex_memwrite), .in_branch(w_id_ex_branch),
        .out_alu_result(w_ex_mem_alu_result), .out_write_data_mem(w_ex_mem_write_data_mem),
        .out_rd(w_ex_mem_rd), .out_zero_flag(w_ex_mem_zero_flag),
        .out_regwrite(w_ex_mem_regwrite), .out_memtoreg(w_ex_mem_memtoreg),
        .out_memread(w_ex_mem_memread), .out_memwrite(w_ex_mem_memwrite), .out_branch(w_ex_mem_branch)
    );

    // Estágio 4: MEM
    stage_mem u_stage_mem (
        .clock(clock),
        .ex_mem_memwrite(w_ex_mem_memwrite),
        .ex_mem_memread(w_ex_mem_memread),
        .ex_mem_alu_result(w_ex_mem_alu_result),
        .ex_mem_write_data_mem(w_ex_mem_write_data_mem),
        .mem_read_data(w_mem_read_data)
    );

    // Registrador MEM/WB
    reg_mem_wb u_reg_mem_wb (
        .clock(clock), .reset(reset),
        .in_mem_read_data(w_mem_read_data),
        .in_alu_result(w_ex_mem_alu_result),
        .in_rd(w_ex_mem_rd),
        .in_regwrite(w_ex_mem_regwrite),
        .in_memtoreg(w_ex_mem_memtoreg),
        .out_mem_read_data(w_mem_wb_mem_read_data),
        .out_alu_result(w_mem_wb_alu_result),
        .out_rd(w_mem_wb_rd),
        .out_regwrite(w_mem_wb_regwrite),
        .out_memtoreg(w_mem_wb_memtoreg)
    );
    
    // Estágio 5: WB
    stage_wb u_stage_wb (
        .mem_wb_memtoreg(w_mem_wb_memtoreg),
        .mem_wb_mem_read_data(w_mem_wb_mem_read_data),
        .mem_wb_alu_result(w_mem_wb_alu_result),
        .wb_write_data_to_regfile(w_wb_write_data_to_regfile)
    );
    
endmodule