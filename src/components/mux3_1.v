// src/components/mux3_1.v
// MUX genérico de 3 para 1
module mux3_1 #(
    parameter WIDTH = 32 // Largura do barramento de dados
)(
    // Inputs
    input      [WIDTH-1:0] in0, // Selecionado por 2'b00
    input      [WIDTH-1:0] in1, // Selecionado por 2'b01
    input      [WIDTH-1:0] in2, // Selecionado por 2'b10
    input      [1:0]         sel,

    // Outputs
    output reg [WIDTH-1:0] out
);

    always @(*) begin
        case (sel)
            2'b00:   out = in0;
            2'b01:   out = in1;
            2'b10:   out = in2;
            default: out = {WIDTH{1'bx}}; // Saída indefinida
        endcase
    end

endmodule