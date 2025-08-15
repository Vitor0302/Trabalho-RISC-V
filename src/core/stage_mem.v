// core/stage_mem.v
module stage_mem (
    // Inputs
    input         clock,
    input         ex_mem_memwrite,
    input         ex_mem_memread,
    input  [31:0] ex_mem_alu_result,
    input  [31:0] ex_mem_write_data_mem,

    // Outputs
    output [31:0] mem_read_data
);

    Memoria_Dados u_dmem (
        .clock(clock),
        .MemWrite(ex_mem_memwrite),
        .MemRead(ex_mem_memread),
        .address(ex_mem_alu_result),
        .write_data(ex_mem_write_data_mem),
        .read_data(mem_read_data)
    );

endmodule