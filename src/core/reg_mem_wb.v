/*
Módulo: reg_mem_wb.v
Descrição: Registro entre os estágios MEM e WB do pipeline.
*/

module reg_mem_wb (
    // Inputs
    input         clock,
    input         reset,
    input  [31:0] in_mem_read_data,
    input  [31:0] in_alu_result,
    input  [4:0]  in_rd,
    input         in_regwrite,
    input         in_memtoreg,

    // Outputs
    output reg [31:0] out_mem_read_data,
    output reg [31:0] out_alu_result,
    output reg [4:0]  out_rd,
    output reg        out_regwrite,
    output reg        out_memtoreg
);

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            out_regwrite <= 1'b0;
            out_memtoreg <= 1'b0;
            out_rd       <= 5'b0;
        end else begin
            out_mem_read_data <= in_mem_read_data;
            out_alu_result    <= in_alu_result;
            out_rd            <= in_rd;
            out_regwrite      <= in_regwrite;
            out_memtoreg      <= in_memtoreg;
        end
    end

endmodule