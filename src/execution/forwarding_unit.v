/*
Módulo da Unidade de Adiantamento (Forwarding)
Este módulo implementa a lógica para resolver hazards de dados.
Ele compara os registradores de origem da instrução no estágio EX
com os registradores de destino das instruções nos estágios MEM e WB.
Com base nisso, gera sinais de controle para os MUXes da entrada da ULA.
*/

module Forwarding_Unit (
    // Destino da instrução no estágio MEM
    input EX_MEM_RegWrite,
    input [4:0] EX_MEM_rd,

    // Destino da instrução no estágio WB
    input MEM_WB_RegWrite,
    input [4:0] MEM_WB_rd,

    // Fontes da instrução no estágio EX
    input [4:0] ID_EX_rs1,
    input [4:0] ID_EX_rs2,

    // Sinais de controle de saída para os MUXes da ULA
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);

    /*
    Codificação dos sinais de Forwarding:
    2'b00: Sem adiantamento (usa valor do banco de registradores)
    2'b01: Adiantar resultado do estágio MEM (vindo da ULA)
    2'b10: Adiantar resultado do estágio WB (vindo da Memória ou ULA)
    */

    always @(*) begin
        // --- Lógica para a primeira entrada da ULA (ForwardA) ---
        if (EX_MEM_RegWrite && (EX_MEM_rd != 5'b0) && (EX_MEM_rd == ID_EX_rs1)) begin
            ForwardA = 2'b01; // Prioridade para o hazard mais recente (MEM -> EX)
        end else if (MEM_WB_RegWrite && (MEM_WB_rd != 5'b0) && (MEM_WB_rd == ID_EX_rs1)) begin
            ForwardA = 2'b10; // Hazard WB -> EX
        end else begin
            ForwardA = 2'b00; // Sem hazard
        end

        // --- Lógica para a segunda entrada da ULA (ForwardB) ---
        if (EX_MEM_RegWrite && (EX_MEM_rd != 5'b0) && (EX_MEM_rd == ID_EX_rs2)) begin
            ForwardB = 2'b01; // Prioridade para o hazard mais recente (MEM -> EX)
        end else if (MEM_WB_RegWrite && (MEM_WB_rd != 5'b0) && (MEM_WB_rd == ID_EX_rs2)) begin
            ForwardB = 2'b10; // Hazard WB -> EX
        end else begin
            ForwardB = 2'b00; // Sem hazard
        end
    end

endmodule