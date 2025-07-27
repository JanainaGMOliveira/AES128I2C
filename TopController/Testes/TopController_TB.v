`timescale 1ns/1ps 

module top_i2c_aes128_TB;

    wire clk;
    reg rst;
    wire scl;
    reg sda_in;
    tri1 sda;

    wire done;
    wire [127:0] saida;

    reg [7:0] master_data;
    reg [263:0] data_128bits;
    reg [7:0] master_address = 8'b11010100;
    reg sda_controle;
    reg [3:0] data_bit_counter;

    integer negedge_detected;
    integer i, j;

    // Flags auxiliares para visualização do STOP
    reg stop_flag;
    reg sda_rising_during_scl_high;
    reg sda_in_prev;  // Verilog puro — usado para detectar flanco de subida

    clockGenerator #(10) clkGenerator(clk); // Gerador de clock geral 100Mhz (10ns)
    clockGenerator #(200) clkGeneratorSCL(scl); // Gerador de clock SCL I2C 5Mhz (200ns)
    top_i2c_aes128 tb_top(saida, done, sda, scl, clk, rst); //Instancia do Modulo TOP

    assign sda = sda_controle ? 1'bz : sda_in; // Controla o valor da linha sda com base no sinal de controle sda_controle.

    always @(negedge scl)
        negedge_detected = 1;

    // Flags de monitoramento de STOP (visualização gráfica)
    always @(posedge clk) begin
        sda_in_prev <= sda_in;

        // Flag contínua: ativa enquanto sda_in = 1 e scl = 1
        sda_rising_during_scl_high <= (sda_in === 1 && scl === 1);

        // Pulso de 1 ciclo: flanco de subida de sda_in enquanto scl = 1
        if (sda_in === 1 && sda_in_prev === 0 && scl === 1)
            stop_flag <= 1;
        else
            stop_flag <= 0;
    end

    initial begin
        rst = 1;
        #15 rst = 0;
        //Chamada para as tasks de teste com os valores (id, palavra, resultado ciphra )
        executarTeste(0, 128'h00112233445566778899aabbccddeeff, 128'h000102030405060708090a0b0c0d0e0f, 128'h69c4e0d86a7b0430d8cdb78070b4c55a);
        executarTeste(1, 128'h3243f6a8885a308d313198a2e0370734, 128'h2b7e151628aed2a6abf7158809cf4f3c, 128'h3925841d02dc09fbdc118597196a0b32);
        executarTeste(2, 128'h00000000000000000000000000000000, 128'h00000000000000000000000000000000, 128'h66e94bd4ef8a2c3b884cfa59ca342b2e);
        executarTeste(3, 128'hffffffffffffffffffffffffffffffff, 128'h00000000000000000000000000000000, 128'h3f5b8cc9ea855a0afa7347d23e8d664e);
        executarTeste(4, 128'haabbccddeeff00112233445566778899, 128'h102030405060708090a0b0c0d0e0f000, 128'h2be52b98821c28a467897944fa4ac1bc);

        #50000;
        $stop;
    end

    task executarTeste(input integer id, input [127:0] palavra, input [127:0] chave, input [127:0] ciphra);
        begin
            //-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-CRIPTOGRAFIA-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
            // Visualização dos resultados obtidos no display
            $display("\n Teste %0d  Criptografia AES-128", id);
            $display("Entrada  = %h", palavra); // Valor da entrada da Criptografia e Base de comparação para a Descriptografia
            $display("Chave    = %h", chave);
            $display("Esperado = %h", ciphra); // Valor de base de comparação na Criptografia e Entrada para a Descriptografia
            
            // Configuração dos dados e envio
            data_128bits = {palavra, chave, 8'h00}; // modo 0 = criptografia
            envia_via_i2c();
            
            //Aguarda o done da FSM
            wait(done);
            $display("Obtido   = %h", saida);
            
            //Comparação dos resultados obtidos na criptografia
            if (saida === ciphra)
                $display("Resultado CORRETO!");
            else
                $display(" Resultado INCORRETO!");
            
            // Reset e atraso antes do proximo teste
            rst = 1;
            #15 rst = 0;
            #3000;

            //-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-DESCRIPTOGRAFIA-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
            // Visualização dos valores no display
            $display("\n Teste %0d  Descriptografia AES-128", id);
            $display("Entrada  = %h", ciphra);
            $display("Chave    = %h", chave);
            $display("Esperado = %h", palavra);

            data_128bits = {ciphra, chave, 8'h01}; // modo 1 = descriptografia
            envia_via_i2c();

            wait(done);
            $display("Obtido   = %h", saida);
            //Comparação dos resultados obtidos
            if (saida === palavra)
                $display("Resultado CORRETO!");
            else
                $display(" Resultado INCORRETO!");

            rst = 1;
            #15 rst = 0;
            #3000;
        end
    endtask

    task envia_via_i2c;
        begin
            data_bit_counter = 0; 
            sda_controle = 0; 
            sda_in = 1;

            @(posedge scl) #20 sda_in = 0;
            @(negedge scl);

            negedge_detected = 0;
            for (i = 7; i >= 0; i = i - 1) begin
                sda_in = master_address[i];
                wait (tb_top.i2c.state == 2 || negedge_detected); // espera pelo ACK do Slave
                negedge_detected = 0; // inicializa o flag indicador de borda de decida do SCL para 0
            end

            sda_controle = 1; //passa o controle da linha sda para o Slave
            wait (tb_top.i2c.state == 3); // espera o slave entrar em estado de READ
            sda_controle = 0;// retoma o controle da linha
            negedge_detected = 0; // inicializa o flag indicador de borda de decida do SCL para 0

            for (j = 263; j > 0; j = j - 8) begin
                master_data = data_128bits[j-:8];
                wait (tb_top.i2c.state == 3); // espera o slave entrar em estado de READ
                for (i = 7; i >= 0; i = i - 1) begin
                    sda_in = master_data[i]; // evia bit a bit cada byte
                    wait (negedge_detected); // espera o SCL mudade de 0 para 1
                    negedge_detected = 0;    // volta o flag indicador de borda de decida do SCL para 0
                end
                sda_controle = 1;  // passa o controle da linha para o slave
                wait (negedge_detected); // espera o tempo do ack
                sda_controle = 0;  // retoma o controle da linha
                negedge_detected = 0;
            end
            //  Enviar stop condition (SDA vai de 0 para 1 com SCL = 1)
            sda_in = 0;
            @(posedge scl) #20 sda_in = 1; 
            negedge_detected = 0;
            wait (negedge_detected); 
        end
    endtask
endmodule

// Clock generator
module clockGenerator #(parameter period = 5)(
    output clk
);
    reg outClk = 0;
    always #(period/2) outClk = ~outClk;
    assign clk = outClk;
endmodule
