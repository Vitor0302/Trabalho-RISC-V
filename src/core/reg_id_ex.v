// core/reg_id_ex.v
module reg_id_ex (
    // Inputs
    input         clock,
    input         reset,
    input         branch_taken,
    input         id_ex_bubble,
    input  [31:0] in_pc,
    input  [31:0] in_read_data_1,
    input  [31:0] in_read_data_2,
    input  [31:0] in_immediate,
    input  [4:0]  in_rs1,
    input  [4:0]  in_rs2,
    input  [4:0]  in_rd,
    input  [2:0]  in_funct3,
    input  [6:0]  in_funct7,
    input         in_regwrite,
    input         in_alusrc,
    input         in_memtoreg,
    input         in_memread,
    input         in_memwrite,
    input         in_branch,
    input  [1:0]  in_aluop,

    // Outputs
    output reg [31:0] out_pc,
    output reg [31:0] out_read_data_1,
    output reg [31:0] out_read_data_2,
    output reg [31:0] out_immediate,
    output reg [4:0]  out_rs1,
    output reg [4:0]  out_rs2,
    output reg [4:0]  out_rd,
    output reg [2:0]  out_funct3,
    output reg [6:0]  out_funct7,
    output reg        out_regwrite,
    output reg        out_alusrc,
    output reg        out_memtoreg,
    output reg        out_memread,
    output reg        out_memwrite,
    output reg        out_branch,
    output reg [1:0]  out_aluop
);

    always @(posedge clock or posedge reset) begin
        if (reset || branch_taken || id_ex_bubble) begin
            out_regwrite <= 0; out_alusrc <= 0; out_memtoreg <= 0;
            out_memread  <= 0; out_memwrite <= 0; out_branch <= 0;
            out_aluop    <= 0;
            // Opcional zerar outros, mas os controles são o mais importante
            out_rd <= 0;
        end else begin
            out_pc            <= in_pc;
            out_read_data_1   <= in_read_data_1;
            out_read_data_2   <= in_read_data_2;
            out_immediate     <= in_immediate;
            out_rs1           <= in_rs1;
            out_rs2           <= in_rs2;
            out_rd            <= in_rd;
            out_funct3        <= in_funct3;
            out_funct7        <= in_funct7;
            out_regwrite      <= in_regwrite;
            out_alusrc        <= in_alusrc;
            out_memtoreg      <= in_memtoreg;
            out_memread       <= in_memread;
            out_memwrite      <= in_memwrite;
            out_branch        <= in_branch;
            out_aluop         <= in_aluop;
        end
    end

endmodule