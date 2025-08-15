// core/reg_if_id.v
module reg_if_id (
    // Inputs
    input         clock,
    input         reset,
    input         if_id_stall,
    input         branch_taken,
    input  [31:0] in_instruction,
    input  [31:0] in_pc,

    // Outputs
    output reg [31:0] out_instruction,
    output reg [31:0] out_pc
);

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            out_instruction <= 32'h00000013; // nop
            out_pc          <= 32'b0;
        end else if (!if_id_stall) begin
            out_instruction <= branch_taken ? 32'h00000013 : in_instruction;
            out_pc          <= in_pc;
        end
    end

endmodule