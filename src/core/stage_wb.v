/*
Módulo: stage_wb
Função: Escreve dados de volta no banco de registradores a partir da memória ou do resultado da ALU.
*/

module stage_wb (
    // Inputs
    input         mem_wb_memtoreg,
    input  [31:0] mem_wb_mem_read_data,
    input  [31:0] mem_wb_alu_result,

    // Outputs
    output [31:0] wb_write_data_to_regfile
);

    mux2_1 #( .WIDTH(32) ) u_mux_wb (
        .in0(mem_wb_alu_result),
        .in1(mem_wb_mem_read_data),
        .sel(mem_wb_memtoreg),
        .out(wb_write_data_to_regfile)
    );

endmodule