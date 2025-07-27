
`timescale 1ns / 100ps

module tb_AddRoundKey();

    reg  [127:0] state_in;
    reg  [127:0] round_key;
    wire [127:0] state_out;

    // Instância
    AddRoundKey tb_Add (
        .state_in(state_in),
        .round_key(round_key),
        .state_out(state_out)
    );

    // Vetores reais convertidos para row-major para não causar problemas
    /*Em AES, os dados são originalmente organizados como uma matriz 4x4 de bytes em ordem column-major (como descrito na norma FIPS-197), 
    mas como os dados estão sendo manipulados diretamente como vetores de 128 bits em Verilog, a conversão para row-major garante que os 
    bits estejam alinhados corretamente com a ordem usada na operação XOR.Essa conversão evita que erros surjam devido a desalinhamento de 
    bytes, especialmente ao testar com vetores de referência oficiais (como os do Apêndice B), onde a consistência da ordem dos bytes é 
    fundamental para validar corretamente a lógica do módulo.*/

    reg [127:0] vetores_in [0:4];
    reg [127:0] vetores_key[0:4];
    reg [127:0] vetores_out[0:4];

    integer i;

    initial begin
        $display("===== Teste AES AddRoundKey =====");

        // Teste 0 - Valores sequenciais (incrementais) para facilitar verificação de XOR
        vetores_in[0]  = 128'h00112233445566778899aabbccddeeff;
        vetores_key[0] = 128'h000102030405060708090a0b0c0d0e0f; //Chave retirada do apendice B
        vetores_out[0] = 128'h00102030405060708090a0b0c0d0e0f0; //resultado vetores_in XOR vetores_key https://xor.pw/#
                            
        // Teste 1 - Vetor Oficial da FIPS-197 (Apêndice B)
        vetores_in[1]  = 128'h3243f6a8885a308d313198a2e0370734;
        vetores_key[1] = 128'h2b7e151628aed2a6abf7158809cf4f3c; //Chave retirada do apendice B
        vetores_out[1] = 128'h193de3bea0f4e22b9ac68d2ae9f84808; //resultado vetores_in XOR vetores_key https://xor.pw/#

        // Teste 2 - Operação de identidade — XOR de 0 com 0 retorna 0.
        vetores_in[2]  = 128'h00000000000000000000000000000000;
        vetores_key[2] = 128'h00000000000000000000000000000000; //Chave retirada do apendice B
        vetores_out[2] = 128'h00000000000000000000000000000000; //resultado vetores_in XOR vetores_key https://xor.pw/#

        // Teste 3 - Operação de identidade — XOR de qualquer valor com 0 devolve o próprio valor.
        vetores_in[3]  = 128'hffffffffffffffffffffffffffffffff;
        vetores_key[3] = 128'h00000000000000000000000000000000;
        vetores_out[3] = 128'hffffffffffffffffffffffffffffffff; //resultado vetores_in XOR vetores_key https://xor.pw/#

        // Teste 4 - Entrada com padrão visual e uma chave com saltos regulares, para verificar funcionalidade de XOR completo.
        vetores_in[4]  = 128'haabbccddeeff00112233445566778899;
        vetores_key[4] = 128'h102030405060708090a0b0c0d0e0f000; //Valor sequencial com saltos regulares
        vetores_out[4] = 128'hba9bfc9dbe9f7091b293f495b6977899; //resultado vetores_in XOR vetores_key https://xor.pw/#
        
        //Loop teste, para cada valor inserido o resultado deverá ser mostrado no display em forma de texto, nas formas de onda iremos obter os valores das saídas
        for (i = 0; i < 5; i = i + 1) begin
            state_in  = vetores_in[i]; // atribuindo os valores da TB à entrada do módulo
            round_key = vetores_key[i]; // atribuindo os valores da TB à entrada do módulo
            #10;
            //visualização dos resultados em formato texto para conferência
            $display("Teste %0d:", i);
            $display("  State In   : %h", state_in);
            $display("  Round Key  : %h", round_key);
            $display("  Resultado  : %h", state_out);
            $display("  Esperado   : %h", vetores_out[i]);
            //faz comparação para saber se o está correto o cálculo do módulo com o valor esperado gerado pela calculadora online
            if (state_out !== vetores_out[i])
                $display("  --> ERRO: resultado incorreto!");
            else
                $display("  --> OK");
            $display("");
        end

        $stop;
    end

endmodule
