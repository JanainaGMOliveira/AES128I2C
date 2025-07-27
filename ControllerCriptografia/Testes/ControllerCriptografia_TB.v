`timescale 1ns/100ps

module controladorCriptografia_TB;

    // Clock, Reset e Controle
    wire clk;
    reg rst;
    reg start;

    // Estado da FSM
    // wire [3:0] estado;

    // Entradas principais
    reg [127:0] chave;
    reg [127:0] palavra;

    // Saídas e intermediários
    wire [127:0] cifra;
    // wire [127:0] auxEstadoEntrada;
    // wire [127:0] auxChaveEntrada;
    // wire [127:0] estadoSaidaAddRoundKey;
    // wire [127:0] estadoSaidaSubBytes;
    // wire [127:0] estadoSaidaShiftRows;
    // wire [127:0] estadoSaidaMixColumns;

    wire done;

    // Instancia gerador de clock com período de 10ns (100 MHz)
    clockGenerator #(10) clkGenerator(clk);

    // Instancia o DUT
    controladorCriptografia tb_cont_crip (
        .cifra(cifra),
        .done(done),
        // .auxEstadoEntrada(auxEstadoEntrada),
        // .auxChaveEntrada(auxChaveEntrada),
        // .estadoSaidaAddRoundKey(estadoSaidaAddRoundKey),
        // .estadoSaidaSubBytes(estadoSaidaSubBytes),
        // .estadoSaidaShiftRows(estadoSaidaShiftRows),
        // .estadoSaidaMixColumns(estadoSaidaMixColumns),
        // .estado(estado),
        .chave(chave),
        .palavra(palavra),
        .start(start),
        .rst(rst),
        .clk(clk)
    );

    // Sequência de testes
    initial begin
        $display("=== AES-128 TESTBENCH ===");

        // Teste 0 - Sequência simples
        palavra = 128'h00112233445566778899aabbccddeeff;
        chave   = 128'h000102030405060708090a0b0c0d0e0f;
        executarTeste(0, 128'h69c4e0d86a7b0430d8cdb78070b4c55a); //Obtido em https://testprotect.com/appendix/AEScalc
        // Teste 1 - Vetor oficial (FIPS-197)
        palavra = 128'h3243f6a8885a308d313198a2e0370734;
        chave   = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        executarTeste(1, 128'h3925841d02dc09fbdc118597196a0b32); //Obtido na pagina 33 do documento: https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.197.pdf

        // Teste 2 - Zero total
        palavra = 128'h00000000000000000000000000000000;
        chave   = 128'h00000000000000000000000000000000;
        executarTeste(2, 128'h66e94bd4ef8a2c3b884cfa59ca342b2e); //Obtido em https://testprotect.com/appendix/AEScalc

        // Teste 3 - Entrada 1 e Chave Zero
        palavra = 128'hffffffffffffffffffffffffffffffff;
        chave   = 128'h00000000000000000000000000000000;
        executarTeste(3, 128'h3f5b8cc9ea855a0afa7347d23e8d664e); //Obtido em https://testprotect.com/appendix/AEScalc

        // Teste 4 - Valor Genérico com saltos regulares
        palavra = 128'haabbccddeeff00112233445566778899;
        chave   = 128'h102030405060708090a0b0c0d0e0f000;
        executarTeste(4, 128'h2be52b98821c28a467897944fa4ac1bc); //Obtido em https://testprotect.com/appendix/AEScalc

        $display("=== Testbench Finalizado ===");
        $stop;
    end

    // Task para execução e verificação do resultado da cifra
    task executarTeste(input integer id, input [127:0] esperado);
        begin
            rst = 1'b0;
            start = 1'b0; #10;

            rst = 1'b1; #20;
            rst = 1'b0; #10;

            start = 1'b1; #15;
            start = 1'b0;

            wait(done);

            $display("\n--------------------------------------------------");
            $display("🔍 Teste %0d", id);
            $display("Cifra esperada: %h", esperado);
            $display("Cifra obtida  : %h", cifra);

            //Comparação dos resultados bit a bit
            if (cifra === esperado) begin
                $display("Teste %0d PASSOU", id);
            end else begin
                $display("Teste %0d FALHOU", id);
                $display("⚠️ Diferença XOR: %h", cifra ^ esperado);
            end
            $display("--------------------------------------------------\n");
        end
    endtask

    // // Monitoramento em tempo real dos estados da FSM, útil para análise das formas de onda
    // always @(posedge clk) begin
    //     case (estado)
    //         4'd0: $display("[S0 - Idle] Estado Inicial: %h", auxEstadoEntrada);
    //         4'd1: $display("[S1 - Expansion Key]");
    //         4'd2: $display("[S2 - AddRoundKey] Resultado: %h", estadoSaidaAddRoundKey);
    //         4'd3: $display("[S3 - SubBytes] Resultado: %h", estadoSaidaSubBytes);
    //         4'd4: $display("[S4 - ShiftRows] Resultado: %h", estadoSaidaShiftRows);
    //         4'd5: $display("[S5 - MixColumns] Resultado: %h", estadoSaidaMixColumns);
    //         4'd6: $display("[S6 - AddRoundKey] Resultado: %h", estadoSaidaAddRoundKey);
    //         4'd7: $display("[S7 - Final] Cifra Final: %h", cifra);
    //     endcase
    // end
endmodule

// Clock Generator (gerador de clock simples)
module clockGenerator #(parameter period = 5)(
    output clk
);
    reg outClk = 1'b0;
    always begin
        #(period/2) outClk = ~outClk;
    end
    assign clk = outClk;
endmodule
