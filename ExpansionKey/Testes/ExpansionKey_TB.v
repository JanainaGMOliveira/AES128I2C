`timescale 1ns/1ps
module tb_expansion_key;

    reg  [127:0] key;
    wire [1407:0] rk_flat; // Vetor para 11 chaves de 128bits
    wire done; // Sinal de controle

    expansion_key tb_expk (
        .key               (key),
        .round_key_flat    (rk_flat),
        .key_expansion_done(done)
    );

    // ---------------------------------------------------------
    // Vetores-referência (formato Apêndice A FIPS-197 / word-order)
    // Referências oficiais: Essas constantes representam os resultados 
    // esperados da expansão da chave conforme a especificação do FIPS-197,
    // em ordem word (linha a linha de 4 palavras de 32 bits). São usados 
    // para comparar os resultados da simulação.
    // ---------------------------------------------------------
    localparam [1407:0] REF0 = {
        128'hd014f9a8c9ee2589e13f0cc8b6630ca6, //Round 0
        128'hac7766f319fadc2128d12941575c006e, //Round 1
        128'head27321b58dbad2312bf5607f8d292f, //Round 2
        128'h4e54f70e5f5fc9f384a64fb24ea6dc4f, //Round 3
        128'h6d88a37a110b3efddbf98641ca0093fd, //Round 4
        128'hd4d1c6f87c839d87caf2b8bc11f915bc, //Round 5
        128'hef44a541a8525b7fb671253bdb0bad00, //Round 6
        128'h3d80477d4716fe3e1e237e446d7a883b, //Round 7
        128'hf2c295f27a96b9435935807a7359f67f, //Round 8
        128'ha0fafe1788542cb123a339392a6c7605, //Round 9
        128'h2b7e151628aed2a6abf7158809cf4f3c  //Round 10
    };

    //–– chave 0
    localparam [127:0] KEY1  = 128'h0;
    localparam [1407:0] REF1 = {
        128'hb4ef5bcb3e92e21123e951cf6f8f188e,
        128'hb1d4d8e28a7db9da1d7bb3de4c664941,
        128'h0ef903333ba9613897060a04511dfa9f,
        128'h217517873550620bacaf6b3cc61bf09b,
        128'hec614b851425758c99ff09376ab49ba7,
        128'h7f2e2b88f8443e098dda7cbbf34b9290,
        128'hee06da7b876a1581759e42b27e91ee2b,
        128'h90973450696ccffaf2f457330b0fac99,
        128'h9b9898c9f9fbfbaa9b9898c9f9fbfbaa,
        128'h62636363626363636263636362636363,
        128'h00000000000000000000000000000000
    };

    //–– chave FF
    localparam [127:0] KEY2  = 128'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff;
    localparam [1407:0] REF2 = {
        128'hd60a3588e472f07b82d2d7858cd7c326, 
        128'h8bf03f233278c5f366a027fe0e0514a3, 
        128'h96337366b988fad054d8e20d68a5335d, 
        128'he90d208d2fbb89b6ed5018dd3c7dd150, 
        128'h71d07db3c6b6a93bc2eb916bd12dc98d, 
        128'he5baf3ceb766d488045d385013c658e6, 
        128'he16abd3e52dc2746b33becd8179b60b6, 
        128'h090e2277b3b69a78e1e7cb9ea4a08c6e, 
        128'hadaeae19bab8b80f525151e6454747f0, 
        128'he8e9e9e917161616e8e9e9e917161616, 
        128'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff
    };

    // Caso 3 – chave fixa 0123…3210  
    localparam [127:0] KEY3  = 128'h0123456789abcdeffedcba9876543210;
    localparam [1407:0] REF3 = {
        128'hc55f24af238d91a058d4f5d551769ba7, // round10
        128'hc9c064aee6d2b50f7b59647509a26e72, // round 9
        128'hdda7a1ee2f12d1a19d8bd17a72fb0a07, // round 8
        128'h0c1e5e31f2b5704fb29900dbef70db7d, // round 7
        128'h52a77a7dfeab2e7e402c70945de9dba6, // round 6
        128'hd4c559d9ac0c5403be875eea1dc5ab32, // round 5
        128'he82338d378c90dda128b0ae9a342f5d8, // round 4
        128'h3d35ff1b90ea35096a420733b1c9ff31, // round 3
        128'h047488a2addfca12faa8323adb8bf802, // round 2
        128'h20008f5fa9ab42b05777f8282123ca38, // round 1
        128'h0123456789abcdeffedcba9876543210  // round 0
    };

    //O Valor DEAD_BEEF é um artifício de desenvolvimento, facil escrever em hexa, fácil identificação, produz várias transições entre 0 e 1 
    //–– Caso 4 : REF0 com round-5 corrompido
    localparam [1407:0] REF4 = {
        REF0[1407:768],                                     
        REF0[767:640] ^ 128'hDEAD_BEEF_DEAD_BEEF_DEAD_BEEF_DEAD_BEEF, // DEAD_BEEF… é apenas um marcador de erro
        REF0[639:0]                                          
    };

    // ----------------------------------------------------------------
    // Vectores de entrada
    // ----------------------------------------------------------------
    reg [127:0] key_vec [0:4]; // 5 chaves de entrada para os testes.
    reg [1407:0] ref_vec [0:4]; // 5 referências esperadas.
    
    //
    initial begin
        key_vec[0] = 128'h2b7e151628aed2a6abf7158809cf4f3c; // Chave padrão do Apêndice A do FIPS-197, usada como referência oficial.
        ref_vec[0] = REF0; // 11 round keys geradas para essa chave, também conforme o Apêndice A (em word-order).
        key_vec[1] = KEY1; // Chave com todos os bits em zero (128'h0).                                  
        ref_vec[1] = REF1; // Valores esperados da expansão de KEY1
        key_vec[2] = KEY2; // Chave com todos os bits em 1                                   
        ref_vec[2] = REF2; // Valores esperados da expansão de KEY2
        key_vec[3] = KEY3; // Chave com sequência 0123456789ABCDEF                                  
        ref_vec[3] = REF3; // Valores esperados da expansão de KEY3
        key_vec[4] = 128'h2b7e151628aed2a6abf7158809cf4f3c; //repete a mesma chave do caso 0. 
        ref_vec[4] = REF4; // Valores esperados da expansão de KEY4 
    end

    // ---------------------------------------------------------
    // Loop de testes
    // ---------------------------------------------------------
    integer t = 0; // numero de testes realizados
    integer r = 0; // varredura dos round_keys
    reg     pass = 1'b0; // resultado da verificação    
    initial begin
        $display("\n===== BATERIA DE TESTES EXPANSAO AES-128 =====");
        for (t = 0; t < 5; t = t + 1) begin
            key = key_vec[t];
            #50;  // DUT contém 40×#1; 50 ns é margem segura

            pass = (rk_flat === ref_vec[t]); //compara bit a bit vetor gerado com vetor de referencia
            $display("\nCaso %0d – chave = %h : %s",
                     t, key, pass ? "PASSOU" : "FALHOU"); // Pass = 1 Passou
                     
            //Verifica quais rounds da chave expandida estão divergindo do esperado, mostra os valores obtidos (obt) e esperados (exp)   
            if (!pass) begin 
                for (r = 0; r <= 10; r = r + 1)
                    if (rk_flat[r*128 +:128] !== ref_vec[t][r*128 +:128])
                        $display("  Diferenca round %0d:\n    obt=%h\n    exp=%h",
                                 r,
                                 rk_flat[r*128 +:128],
                                 ref_vec[t][r*128 +:128]);
            end
        end
        $stop;
    end
endmodule
