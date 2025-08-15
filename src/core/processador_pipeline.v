/*
Módulo Top-Level do Processador RISC-V com Pipeline de 5 Estágios (CORRIGIDO)
Grupo 12: lh, sh, sub, or, andi, srl, beq
*/
module processador_pipeline(
    input clock,
    input reset
);

    // =================================================================
    // --- SINAIS E FIOS ---
    // =================================================================

    // --- Sinais da Unidade de Hazard ---
    wire w_pc_stall, w_if_id_stall, w_id_ex_bubble;

    // --- Estágio IF: Busca de Instrução ---
    // CORREÇÃO: w_pc_current agora é um 'reg'
    reg [31:0]  w_pc_current;
    wire [31:0] w_pc_next, w_pc_plus_4;
    wire [31:0] w_instruction;
    wire        w_branch_taken;
    wire [31:0] w_branch_target_addr;

    // --- Registrador de Pipeline: IF/ID ---
    reg [31:0] IF_ID_instruction;
    reg [31:0] IF_ID_pc_plus_4;
    reg [31:0] IF_ID_pc;

    // --- Estágio ID: Decodificação ---
    wire [6:0] ID_opcode = IF_ID_instruction[6:0];
    wire [4:0] ID_rs1    = IF_ID_instruction[19:15];
    wire [4:0] ID_rs2    = IF_ID_instruction[24:20];
    wire [4:0] ID_rd     = IF_ID_instruction[11:7];
    wire [6:0] ID_funct7 = IF_ID_instruction[31:25];
    wire [2:0] ID_funct3 = IF_ID_instruction[14:12];

    wire ID_RegWrite, ID_ALUSrc, ID_MemToReg, ID_MemRead, ID_MemWrite, ID_Branch;
    wire [1:0] ID_ALUOp;
    
    wire [31:0] ID_read_data_1, ID_read_data_2;
    wire [31:0] ID_immediate_extended;

    // --- Registrador de Pipeline: ID/EX ---
    reg [31:0] ID_EX_pc;
    reg [31:0] ID_EX_read_data_1, ID_EX_read_data_2;
    reg [31:0] ID_EX_immediate;
    reg [4:0]  ID_EX_rs1, ID_EX_rs2, ID_EX_rd;
    reg        ID_EX_RegWrite, ID_EX_ALUSrc, ID_EX_MemToReg, ID_EX_MemRead, ID_EX_MemWrite, ID_EX_Branch;
    reg [1:0]  ID_EX_ALUOp;
    reg [2:0]  ID_EX_funct3;
    reg [6:0]  ID_EX_funct7;

    // --- Estágio EX: Execução ---
    wire [1:0]  EX_ForwardA, EX_ForwardB;
    wire [3:0]  EX_Final_ALU_Control;
    wire [31:0] EX_alu_input_1, EX_alu_input_2_forwarded, EX_alu_input_2_final;
    wire [31:0] EX_alu_result;
    wire        EX_alu_zero_flag;
    
    // --- Registrador de Pipeline: EX/MEM ---
    reg [31:0] EX_MEM_alu_result;
    reg [31:0] EX_MEM_write_data_mem;
    reg [4:0]  EX_MEM_rd;
    reg        EX_MEM_RegWrite, EX_MEM_MemToReg, EX_MEM_MemRead, EX_MEM_MemWrite, EX_MEM_Branch;
    reg        EX_MEM_zero_flag;

    // --- Estágio MEM: Acesso à Memória ---
    wire [31:0] MEM_mem_read_data;

    // --- Registrador de Pipeline: MEM/WB ---
    reg [31:0] MEM_WB_mem_read_data;
    reg [31:0] MEM_WB_alu_result;
    reg [4:0]  MEM_WB_rd;
    reg        MEM_WB_RegWrite, MEM_WB_MemToReg;
    
    // --- Estágio WB: Escrita de Volta ---
    wire [31:0] WB_write_data_to_regfile;


    // =================================================================
    // --- ESTÁGIO 1: IF (BUSCA DE INSTRUÇÃO) ---
    // =================================================================

    always @(posedge clock or posedge reset) begin
        if (reset)
            w_pc_current <= 32'b0;
        else if (!w_pc_stall)
            w_pc_current <= w_pc_next;
    end

    assign w_pc_plus_4 = w_pc_current + 32'd4;
    assign w_branch_taken = EX_MEM_Branch & EX_MEM_zero_flag;
    assign w_pc_next = w_branch_taken ? w_branch_target_addr : w_pc_plus_4;

    Memoria_Instrucao u_imem (
        .address(w_pc_current),
        .instruction(w_instruction)
    );

    // =================================================================
    // --- REGISTRADOR DE PIPELINE: IF/ID ---
    // =================================================================

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            IF_ID_instruction <= 32'h00000013; // nop
            IF_ID_pc_plus_4   <= 32'b0;
            IF_ID_pc          <= 32'b0;
        end else if (!w_if_id_stall) begin
            IF_ID_instruction <= w_branch_taken ? 32'h00000013 : w_instruction; // addi x0, x0, 0
            IF_ID_pc_plus_4   <= w_pc_plus_4;
            IF_ID_pc          <= w_pc_current;
        end
    end
    
    // =================================================================
    // --- ESTÁGIO 2: ID (DECODIFICAÇÃO E BANCO DE REGISTRADORES) ---
    // =================================================================

    Unidade_Controle_Principal u_main_control (
        .opcode(ID_opcode),
        .RegWrite(ID_RegWrite), .ALUSrc(ID_ALUSrc), .MemToReg(ID_MemToReg),
        .MemRead(ID_MemRead), .MemWrite(ID_MemWrite), .Branch(ID_Branch),
        .ALUOp(ID_ALUOp)
    );

    REG_FILE u_regfile (
        .clock(clock), .reset(reset),
        .regwrite(MEM_WB_RegWrite),
        .read_reg_num1(ID_rs1),
        .read_reg_num2(ID_rs2),
        .write_reg(MEM_WB_rd),
        .write_data(WB_write_data_to_regfile),
        .read_data1(ID_read_data_1),
        .read_data2(ID_read_data_2)
    );

    assign ID_immediate_extended = (ID_opcode == 7'b0100011) ? {{20{IF_ID_instruction[31]}}, IF_ID_instruction[31:25], IF_ID_instruction[11:7]} :
                                   (ID_opcode == 7'b1100011) ? {{20{IF_ID_instruction[31]}}, IF_ID_instruction[7], IF_ID_instruction[30:25], IF_ID_instruction[11:8], 1'b0} :
                                                               {{20{IF_ID_instruction[31]}}, IF_ID_instruction[31:20]};

    Hazard_Detection_Unit u_hazard_detection (
        .IF_ID_rs1(ID_rs1),
        .IF_ID_rs2(ID_rs2),
        .ID_EX_MemRead(ID_EX_MemRead),
        .ID_EX_rd(ID_EX_rd),
        .PC_Stall(w_pc_stall),
        .IF_ID_Stall(w_if_id_stall),
        .ID_EX_Bubble(w_id_ex_bubble)
    );

    // =================================================================
    // --- REGISTRADOR DE PIPELINE: ID/EX ---
    // =================================================================
    
    always @(posedge clock or posedge reset) begin
        if (reset || w_branch_taken) begin
            ID_EX_RegWrite <= 0; ID_EX_ALUSrc <= 0; ID_EX_MemToReg <= 0;
            ID_EX_MemRead <= 0; ID_EX_MemWrite <= 0; ID_EX_Branch <= 0;
            ID_EX_ALUOp <= 0;
        end else if (w_id_ex_bubble) begin
            ID_EX_RegWrite <= 0; ID_EX_ALUSrc <= 0; ID_EX_MemToReg <= 0;
            ID_EX_MemRead <= 0; ID_EX_MemWrite <= 0; ID_EX_Branch <= 0;
            ID_EX_ALUOp <= 0;
        end else begin
            ID_EX_pc <= IF_ID_pc;
            ID_EX_read_data_1 <= ID_read_data_1;
            ID_EX_read_data_2 <= ID_read_data_2;
            ID_EX_immediate <= ID_immediate_extended;
            ID_EX_rs1 <= ID_rs1;
            ID_EX_rs2 <= ID_rs2;
            ID_EX_rd <= ID_rd;
            ID_EX_funct3 <= ID_funct3;
            ID_EX_funct7 <= ID_funct7;
            ID_EX_RegWrite <= ID_RegWrite;
            ID_EX_ALUSrc <= ID_ALUSrc;
            ID_EX_MemToReg <= ID_MemToReg;
            ID_EX_MemRead <= ID_MemRead;
            ID_EX_MemWrite <= ID_MemWrite;
            ID_EX_Branch <= ID_Branch;
            ID_EX_ALUOp <= ID_ALUOp;
        end
    end

    // =================================================================
    // --- ESTÁGIO 3: EX (EXECUÇÃO) ---
    // =================================================================

    Forwarding_Unit u_forwarding (
        .EX_MEM_RegWrite(EX_MEM_RegWrite), .EX_MEM_rd(EX_MEM_rd),
        .MEM_WB_RegWrite(MEM_WB_RegWrite), .MEM_WB_rd(MEM_WB_rd),
        .ID_EX_rs1(ID_EX_rs1), .ID_EX_rs2(ID_EX_rs2),
        .ForwardA(EX_ForwardA), .ForwardB(EX_ForwardB)
    );

    assign EX_alu_input_1 = (EX_ForwardA == 2'b00) ? ID_EX_read_data_1 :
                            (EX_ForwardA == 2'b01) ? EX_MEM_alu_result :
                                                     WB_write_data_to_regfile;

    assign EX_alu_input_2_forwarded = (EX_ForwardB == 2'b00) ? ID_EX_read_data_2 :
                                      (EX_ForwardB == 2'b01) ? EX_MEM_alu_result :
                                                               WB_write_data_to_regfile;

    assign EX_alu_input_2_final = ID_EX_ALUSrc ? ID_EX_immediate : EX_alu_input_2_forwarded;

    Unidade_Controle_ULA u_alu_control (
        .ALUOp(ID_EX_ALUOp),
        .funct7(ID_EX_funct7),
        .funct3(ID_EX_funct3),
        .alu_control_out(EX_Final_ALU_Control)
    );

    ULA u_alu (
        .in1(EX_alu_input_1),
        .in2(EX_alu_input_2_final),
        .ula_control(EX_Final_ALU_Control),
        .ula_result(EX_alu_result),
        .zero_flag(EX_alu_zero_flag)
    );
    
    assign w_branch_target_addr = ID_EX_pc + ID_EX_immediate;

    // =================================================================
    // --- REGISTRADOR DE PIPELINE: EX/MEM ---
    // =================================================================
    
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            EX_MEM_RegWrite <= 1'b0;
            EX_MEM_MemToReg <= 1'b0;
            EX_MEM_MemRead  <= 1'b0;
            EX_MEM_MemWrite <= 1'b0;
            EX_MEM_Branch   <= 1'b0;
            EX_MEM_rd       <= 5'b0;
        end else begin
            EX_MEM_alu_result <= EX_alu_result;
            EX_MEM_write_data_mem <= EX_alu_input_2_forwarded;
            EX_MEM_rd <= ID_EX_rd;
            EX_MEM_zero_flag <= EX_alu_zero_flag;
            EX_MEM_RegWrite <= ID_EX_RegWrite;
            EX_MEM_MemToReg <= ID_EX_MemToReg;
            EX_MEM_MemRead <= ID_EX_MemRead;
            EX_MEM_MemWrite <= ID_EX_MemWrite;
            EX_MEM_Branch <= ID_EX_Branch;
        end
    end

    // =================================================================
    // --- ESTÁGIO 4: MEM (ACESSO À MEMÓRIA) ---
    // =================================================================

    Memoria_Dados u_dmem (
        .clock(clock),
        .MemWrite(EX_MEM_MemWrite),
        .MemRead(EX_MEM_MemRead),
        .address(EX_MEM_alu_result),
        .write_data(EX_MEM_write_data_mem),
        .read_data(MEM_mem_read_data)
    );

    // =================================================================
    // --- REGISTRADOR DE PIPELINE: MEM/WB ---
    // =================================================================
    
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            MEM_WB_RegWrite <= 1'b0;
            MEM_WB_MemToReg <= 1'b0;
            MEM_WB_rd       <= 5'b0;
        end else begin
            MEM_WB_mem_read_data <= MEM_mem_read_data;
            MEM_WB_alu_result <= EX_MEM_alu_result;
            MEM_WB_rd <= EX_MEM_rd;
            MEM_WB_RegWrite <= EX_MEM_RegWrite;
            MEM_WB_MemToReg <= EX_MEM_MemToReg;
        end
    end

    // =================================================================
    // --- ESTÁGIO 5: WB (ESCRITA DE VOLTA) ---
    // =================================================================

    assign WB_write_data_to_regfile = MEM_WB_MemToReg ? MEM_WB_mem_read_data : MEM_WB_alu_result;

endmodule