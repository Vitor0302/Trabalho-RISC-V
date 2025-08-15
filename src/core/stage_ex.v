/*
Módulo: stage_ex
Função: Executa operações aritméticas e lógicas, calcula endereços de desvio e prepara dados para escrita na memória.
*/

module stage_ex (
    // Inputs
    input  [31:0] id_ex_pc,
    input  [31:0] id_ex_read_data_1,
    input  [31:0] id_ex_read_data_2,
    input  [31:0] id_ex_immediate,
    input  [1:0]  forward_a,
    input  [1:0]  forward_b,
    input         id_ex_alusrc,
    input  [1:0]  id_ex_aluop,
    input  [6:0]  id_ex_funct7,
    input  [2:0]  id_ex_funct3,
    input  [31:0] ex_mem_alu_result_fwd,
    input  [31:0] wb_write_data_fwd,

    // Outputs
    output [31:0] ex_alu_result,
    output        ex_zero_flag,
    output [31:0] ex_branch_target_addr,
    output [31:0] ex_write_data_mem
);

    wire [3:0]  final_alu_control;
    wire [31:0] alu_input_1, alu_input_2_forwarded, alu_input_2_final;

    // MUX Forwarding A
    mux3_1 #( .WIDTH(32) ) u_mux_fwd_a (
        .in0(id_ex_read_data_1),
        .in1(ex_mem_alu_result_fwd),
        .in2(wb_write_data_fwd),
        .sel(forward_a),
        .out(alu_input_1)
    );
    
    // MUX Forwarding B
    mux3_1 #( .WIDTH(32) ) u_mux_fwd_b (
        .in0(id_ex_read_data_2),
        .in1(ex_mem_alu_result_fwd),
        .in2(wb_write_data_fwd),
        .sel(forward_b),
        .out(alu_input_2_forwarded)
    );
    
    assign ex_write_data_mem = alu_input_2_forwarded;

    // MUX ALUSrc
    mux2_1 #( .WIDTH(32) ) u_mux_alusrc (
        .in0(alu_input_2_forwarded),
        .in1(id_ex_immediate),
        .sel(id_ex_alusrc),
        .out(alu_input_2_final)
    );

    Unidade_Controle_ULA u_alu_control (
        .ALUOp(id_ex_aluop),
        .funct7(id_ex_funct7),
        .funct3(id_ex_funct3),
        .alu_control_out(final_alu_control)
    );

    ULA u_alu (
        .in1(alu_input_1),
        .in2(alu_input_2_final),
        .ula_control(final_alu_control),
        .ula_result(ex_alu_result),
        .zero_flag(ex_zero_flag)
    );

    assign ex_branch_target_addr = id_ex_pc + id_ex_immediate;

endmodule