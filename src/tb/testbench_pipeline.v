/*
Testbench para o Processador RISC-V Modularizado
*/

`timescale 1ns/1ps

module testbench_pipeline;

    reg clock;
    reg reset;
    integer i;

    // << ALTERAÇÃO 1: Mudar o nome do módulo instanciado >>
    // Instancia o nosso processador com pipeline MODULARIZADO
    processador_pipeline_modular DUT (
        .clock(clock),
        .reset(reset)
    );

    // Geração do Clock
    initial begin
        clock = 0;
        forever #10 clock = ~clock; // Período de 20ns
    end

    // Controle da Simulação, Inicialização e LOG DETALHADO
    initial begin
        $dumpfile("../sim/waveform_pipeline.vcd");
        $dumpvars(0, DUT);

        $display("\nIniciando simulacao do processador RISC-V com PIPELINE - Grupo 12");
        $display("Instrucoes suportadas: lh, sh, sub, or, andi, srl, beq\n");

        // 1. Aplica o reset
        reset = 1;
        #15;
        reset = 0;

        // 2. Inicializa a Memória de Dados
        $display("--- INICIALIZANDO MEMORIA DE DADOS ---");
        // << ALTERAÇÃO 2: Atualizar o caminho para a memória de dados >>
        DUT.u_stage_mem.u_dmem.data_memory[0] = 32'd10; 
        DUT.u_stage_mem.u_dmem.data_memory[1] = 32'd3;  
        $display("Mem[0] = 10, Mem[4] = 3\n");

        $display("\n--- INICIO DA EXECUCAO DO PROGRAMA ---\n");
        
        // Ciclos de 1 a 4
        #20; $display("--- Ciclo 1 ---");
        $display("  IF : Buscando instrucao em 0x00 (lh x10, 0(x0))");
        $display("  ID/EX/MEM/WB: <vazio>\n");
        #20; $display("--- Ciclo 2 ---");
        $display("  IF : Buscando instrucao em 0x04 (lh x11, 4(x0))");
        $display("  ID : Decodificando lh x10");
        $display("  EX/MEM/WB: <vazio>\n");
        #20; $display("--- Ciclo 3 ---");
        $display("  IF : Buscando instrucao em 0x08 (sub x12, x10, x11)");
        $display("  ID : Decodificando lh x11");
        $display("  EX : Executando lh x10 (Calculando endereco 0+x0)");
        $display("  MEM/WB: <vazio>\n");
        #20; $display("--- Ciclo 4 ---");
        $display("  IF : Buscando instrucao em 0x0C (or x13, x10, x11)");
        $display("  ID : Decodificando sub x12, x10, x11");
        $display("  EX : Executando lh x11 (Calculando endereco 4+x0)");
        $display("  MEM: Acessando Mem[0] para lh x10");
        $display("  WB : <vazio>\n");

        // Ciclo 5
        #20; $display("--- Ciclo 5 ---");
        $display("  IF : Buscando instrucao em 0x10 (andi x14, x10, 8)");
        $display("  ID : Decodificando or x13, x10, x11");
        $display("  EX : Executando sub x12 (Operandos adiantados de MEM e WB!)");
        $display("  MEM: Acessando Mem[4] para lh x11");
        // << ALTERAÇÃO 2: Atualizar o caminho para o banco de registradores >>
        $display("  WB : Escrevendo resultado de lh x10 em x10. Resultado: x10 = %d\n", DUT.u_stage_id.u_regfile.reg_memory[10]);

        // Ciclo 6
        #20; $display("--- Ciclo 6 ---");
        $display("  IF : Buscando instrucao em 0x14 (srl x15, x10, 1)");
        $display("  ID : Decodificando andi x14, x10, 8");
        $display("  EX : Executando or x13");
        $display("  MEM: <sem acesso>");
        // << ALTERAÇÃO 2: Atualizar o caminho para o banco de registradores >>
        $display("  WB : Escrevendo resultado de lh x11 em x11. Resultado: x11 = %d\n", DUT.u_stage_id.u_regfile.reg_memory[11]);

        // Ciclo 7
        #20; $display("--- Ciclo 7 ---");
        $display("  IF : Buscando instrucao em 0x18 (beq x14, x10, 4)");
        $display("  ID : Decodificando srl x15, x10, 1");
        $display("  EX : Executando andi x14");
        $display("  MEM: <sem acesso>");
        // << ALTERAÇÃO 2: Atualizar o caminho para o fio de writeback >>
        $display("  WB : Escrevendo resultado de sub em x12. Resultado: x12 = %d\n", DUT.w_wb_write_data_to_regfile);

        // Ciclo 8
        #20; $display("--- Ciclo 8 ---");
        $display("  IF : Buscando instrucao em 0x1C (sh x12, 8(x0))");
        $display("  ID : Decodificando beq x14, x10, 4");
        $display("  EX : Executando srl x15");
        $display("  MEM: <sem acesso>");
        // << ALTERAÇÃO 2: Atualizar o caminho para o fio de writeback >>
        $display("  WB : Escrevendo resultado de or em x13. Resultado: x13 = %d\n", DUT.w_wb_write_data_to_regfile);

        // Ciclo 9
        #20; $display("--- Ciclo 9 ---");
        $display("  IF : Buscando instrucao em 0x20 (beq x0, x0, 0)");
        $display("  ID : Decodificando sh x12, 8(x0)");
        // << ALTERAÇÃO 2: Atualizar o caminho para o banco de registradores >>
        $display("  EX : Executando beq x14, x10 (Comparando %d e %d). Desvio NAO sera tomado.", DUT.u_stage_id.u_regfile.reg_memory[14], DUT.u_stage_id.u_regfile.reg_memory[10]);
        $display("  MEM: <sem acesso>");
        // << ALTERAÇÃO 2: Atualizar o caminho para o fio de writeback >>
        $display("  WB : Escrevendo resultado de andi em x14. Resultado: x14 = %d\n", DUT.w_wb_write_data_to_regfile);

        // Ciclo 10
        #20; $display("--- Ciclo 10 ---");
        $display("  IF : Buscando proxima instrucao... (PC continua em +4)");
        $display("  ID : Decodificando beq x0, x0, 0");
        $display("  EX : Executando sh x12 (Calculando endereco 8+x0)");
        $display("  MEM: <sem acesso>");
        // << ALTERAÇÃO 2: Atualizar o caminho para o fio de writeback >>
        $display("  WB : Escrevendo resultado de srl em x15. Resultado: x15 = %d\n", DUT.w_wb_write_data_to_regfile);

        // Ciclo 11
        #20; $display("--- Ciclo 11 ---");
        $display("  ID : <Instrucao apos o beq sendo anulada (flush)>");
        $display("  EX : Executando beq x0, x0. Desvio SERA tomado! PC sera 0x20.");
        // << ALTERAÇÃO 2: Atualizar o caminho para o sinal de dados de escrita >>
        $display("  MEM: Escrevendo valor de x12 (%d) em Mem[8] para sh", DUT.w_ex_mem_write_data_mem);
        $display("  WB : <sem escrita>\n");

        // Ciclo 12
        #20; $display("--- Ciclo 12 ---");
        $display("  IF : Buscando instrucao em 0x20 (beq x0, x0, 0) - Loop iniciado.");
        $display("  ID : <bolha>");
        $display("  EX : <bolha>");
        $display("  MEM: <sem acesso>");
        $display("  WB : <sem escrita>\n");

        #40; // Deixa rodar mais alguns ciclos

        // 4. Exibe o estado final geral
        $display("\n================ ESTADO FINAL ================");
        $display("\n--- Registradores ---");
        for (i=0; i<32; i=i+4) begin
            // << ALTERAÇÃO 2: Atualizar o caminho para o banco de registradores >>
            $display("x%02d: 0x%h    x%02d: 0x%h    x%02d: 0x%h    x%02d: 0x%h",
                i, DUT.u_stage_id.u_regfile.reg_memory[i], i+1, DUT.u_stage_id.u_regfile.reg_memory[i+1],
                i+2, DUT.u_stage_id.u_regfile.reg_memory[i+2], i+3, DUT.u_stage_id.u_regfile.reg_memory[i+3]);
        end

        $display("\n--- Memoria de Dados (enderecos 0-36) ---");
        for (i=0; i<10; i=i+1) begin
            // << ALTERAÇÃO 2: Atualizar o caminho para a memória de dados >>
            $display("Mem[%d]: 0x%h (%d)", i*4, DUT.u_stage_mem.u_dmem.data_memory[i], DUT.u_stage_mem.u_dmem.data_memory[i]);
        end

        $display("\n==========================================");

        $finish; 
    end

endmodule