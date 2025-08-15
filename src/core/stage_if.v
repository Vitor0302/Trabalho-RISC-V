// core/stage_if.v
module stage_if (
    // Inputs
    input         clock,
    input         reset,
    input         pc_stall,
    input         branch_taken,
    input  [31:0] branch_target_addr,

    // Outputs
    output [31:0] instruction,
    output [31:0] pc_current
);

    reg  [31:0] r_pc_current;
    wire [31:0] w_pc_next, w_pc_plus_4;

    always @(posedge clock or posedge reset) begin
        if (reset)
            r_pc_current <= 32'b0;
        else if (!pc_stall)
            r_pc_current <= w_pc_next;
    end

    assign pc_current = r_pc_current;
    assign w_pc_plus_4 = pc_current + 32'd4;

    // 'assign w_pc_next = branch_taken ? branch_target_addr : w_pc_plus_4;' FOI SUBSTITUÍDO POR:
    mux2_1 #( .WIDTH(32) ) u_mux_pc (
        .in0(w_pc_plus_4),
        .in1(branch_target_addr),
        .sel(branch_taken),
        .out(w_pc_next)
    );

    Memoria_Instrucao u_imem (
        .address(pc_current),
        .instruction(instruction)
    );

endmodule