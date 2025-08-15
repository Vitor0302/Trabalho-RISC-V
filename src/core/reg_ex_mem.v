// core/reg_ex_mem.v
module reg_ex_mem (
    // Inputs
    input         clock,
    input         reset,
    input  [31:0] in_alu_result,
    input  [31:0] in_write_data_mem,
    input  [4:0]  in_rd,
    input         in_zero_flag,
    input         in_regwrite,
    input         in_memtoreg,
    input         in_memread,
    input         in_memwrite,
    input         in_branch,

    // Outputs
    output reg [31:0] out_alu_result,
    output reg [31:0] out_write_data_mem,
    output reg [4:0]  out_rd,
    output reg        out_zero_flag,
    output reg        out_regwrite,
    output reg        out_memtoreg,
    output reg        out_memread,
    output reg        out_memwrite,
    output reg        out_branch
);

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            out_regwrite <= 1'b0; out_memtoreg <= 1'b0;
            out_memread  <= 1'b0; out_memwrite <= 1'b0;
            out_branch   <= 1'b0; out_rd       <= 5'b0;
        end else begin
            out_alu_result    <= in_alu_result;
            out_write_data_mem<= in_write_data_mem;
            out_rd            <= in_rd;
            out_zero_flag     <= in_zero_flag;
            out_regwrite      <= in_regwrite;
            out_memtoreg      <= in_memtoreg;
            out_memread       <= in_memread;
            out_memwrite      <= in_memwrite;
            out_branch        <= in_branch;
        end
    end
endmodule