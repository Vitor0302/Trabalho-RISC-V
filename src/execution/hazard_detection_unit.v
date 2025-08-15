/*
Módulo da Unidade de Detecção de Hazard (Stall)
Este módulo detecta hazards do tipo load-use, que não podem ser resolvidos
apenas por adiantamento.
Se uma instrução no estágio ID depende do resultado de uma instrução de load
no estágio EX, o módulo gera sinais para paralisar o PC, o estágio IF/ID
e injetar uma bolha (nop) no estágio ID/EX.
*/

module Hazard_Detection_Unit (
    // Instrução no estágio ID (entradas para checar seus operandos)
    input [4:0] IF_ID_rs1,
    input [4:0] IF_ID_rs2,

    // Instrução no estágio EX (para ver se é um load)
    input ID_EX_MemRead,
    input [4:0] ID_EX_rd,

    // Sinais de controle de saída
    output reg PC_Stall,     // Sinal para não atualizar o PC
    output reg IF_ID_Stall,  // Sinal para não atualizar o registrador IF/ID
    output reg ID_EX_Bubble  // Sinal para injetar uma bolha (nop)
);

    always @(*) begin
        // Verifica a condição de load-use
        if (ID_EX_MemRead && // Se a instrução em EX está lendo da memória...
           ( (ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2) ) && // ...e seu destino é uma das fontes da instrução em ID...
           (ID_EX_rd != 5'b0) ) // ...e o destino não é o registrador x0.
        begin
            // Hazard detectado -> Ativa os sinais de stall e bubble.
            PC_Stall = 1'b1;
            IF_ID_Stall = 1'b1;
            ID_EX_Bubble = 1'b1;
        end else begin
            // Nenhuma condição de hazard, operação normal.
            PC_Stall = 1'b0;
            IF_ID_Stall = 1'b0;
            ID_EX_Bubble = 1'b0;
        end
    end

endmodule