/*
Módulo de Unidade de Controle da ULA
Este módulo implementa a lógica de controle da ULA, gerando o sinal de controle 
de 4 bits baseado nos sinais de controle ALUOp, funct7 e funct3.
*/

module Unidade_Controle_ULA (
    input  [1:0]  ALUOp,                // Sinal de controle da ALU
    input  [6:0]  funct7,               // Função de 7 bits para operações R
    input  [2:0]  funct3,               // Função de 3 bits para operações R
    output reg [3:0]  alu_control_out   // Sinal de controle de 4 bits para a ULA
);
    localparam ALU_AND = 4'b0000, ALU_OR  = 4'b0001, ALU_ADD = 4'b0010, ALU_SUB = 4'b0100, ALU_SRL = 4'b0101;

    always @(*) begin
        case (ALUOp)
            2'b00: alu_control_out = ALU_ADD; // Comando para SOMA
            2'b01: alu_control_out = ALU_SUB; // Comando para SUB
            2'b11: alu_control_out = ALU_AND; // Comando para AND
            2'b10: begin                      // Comando para decodificar Tipo-R
                case (funct3)
                    3'b000: if (funct7 == 7'b0100000) alu_control_out = ALU_SUB; else alu_control_out = ALU_ADD; // ADD ou SUB
                    3'b110: alu_control_out = ALU_OR;c
                    3'b101: if (funct7 == 7'b0000000) alu_control_out = ALU_SRL; else alu_control_out = 4'hX;
                    default: alu_control_out = 4'hX; 
                endcase
            end
            default: alu_control_out = 4'hX;
        endcase
    end
endmodule