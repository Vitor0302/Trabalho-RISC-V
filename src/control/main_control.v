// control/main_control.v
/*
Módulo de Unidade de Controle Principal
Este módulo implementa a lógica de controle principal do processador, gerando sinais 
de controle baseados no opcode da instrução.
Ele determina se a instrução é de tipo R, I, S ou B e gera os sinais de controle 
apropriados para a execução da instrução.
*/

module Unidade_Controle_Principal (
    input  [6:0] opcode,    // Opcode da instrução
    output reg    RegWrite, // Sinal que habilita a escrita no banco de registradores
    output reg    ALUSrc,   // Sinal que seleciona a fonte do segundo operando da ULA
    output reg    MemToReg, // Sinal que seleciona a fonte do dado a ser escrito no registrador
    output reg    MemRead,  // Sinal que habilita a leitura da memória de dados
    output reg    MemWrite, // Sinal que habilita a escrita na memória de dados
    output reg    Branch,   // Sinal que habilita o branch
    output reg [1:0] ALUOp
);

    always @(*) begin
        // Valores padrão seguros para evitar comportamento inesperado
        RegWrite = 1'b0; ALUSrc = 1'b0; MemToReg = 1'b0; MemRead  = 1'b0;
        MemWrite = 1'b0; Branch = 1'b0; ALUOp    = 2'bxx; // Indefinido

        case (opcode)
            // Tipo-R (sub, or, srl)
            7'b0110011: begin
                RegWrite = 1'b1; ALUSrc = 1'b0; MemToReg = 1'b0; MemRead = 1'b0;
                MemWrite = 1'b0; Branch = 1'b0; ALUOp    = 2'b10; // Usar Functs
            end
            // Tipo-I Load (lh)
            7'b0000011: begin
                RegWrite = 1'b1; ALUSrc = 1'b1; MemToReg = 1'b1; MemRead = 1'b1;
                MemWrite = 1'b0; Branch = 1'b0; ALUOp    = 2'b00; // SOMA
            end
            // Tipo-I Imediato (andi)
            7'b0010011: begin
                RegWrite = 1'b1; ALUSrc = 1'b1; MemToReg = 1'b0; MemRead = 1'b0;
                MemWrite = 1'b0; Branch = 1'b0; ALUOp    = 2'b11; // AND
            end
            // Tipo-S Store (sh)
            7'b0100011: begin
                RegWrite = 1'b0; ALUSrc = 1'b1; MemToReg = 1'bx; // Don't Care
                MemRead  = 1'b0; MemWrite = 1'b1; Branch = 1'b0; ALUOp    = 2'b00; // SOMA
            end
            // Tipo-B Branch (beq)
            7'b1100011: begin
                RegWrite = 1'b0; ALUSrc = 1'b0; MemToReg = 1'bx; // Don't Care
                MemRead  = 1'b0; MemWrite = 1'b0; Branch = 1'b1; ALUOp    = 2'b01; // SUB
            end
        endcase
    end
endmodule