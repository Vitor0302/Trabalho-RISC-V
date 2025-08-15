// src/components/mux2_1.v
// MUX genérico de 2 para 1
module mux2_1 #(
    parameter WIDTH = 32 // Largura do barramento de dados
)(
    // Inputs
    input      [WIDTH-1:0] in0,
    input      [WIDTH-1:0] in1,
    input                  sel,

    // Outputs
    output reg [WIDTH-1:0] out
);

    always @(*) begin
        case (sel)
            1'b0: out = in0;
            1'b1: out = in1;
            default: out = {WIDTH{1'bx}}; // Saída indefinida para seletor inválido
        endcase
    end

endmodule