`timescale 1ns / 1ps

// Módulo responsável por gerar as chaves de rodada modificadas (dw[i])
// para serem usadas no modo de descriptografia do AES-128.
// A única diferença em relação à expansão normal é que as chaves das
// rodadas intermediárias (rounds 1 a 9) passam por InvMixColumns.

module keyexpansion_eic (
    input  [127:0] key,                     // Chave original de 128 bits (4 words de 32 bits)
    output reg [1407:0] round_key_eic_flat, // 11 chaves de rodada de 128 bits (11 * 128 = 1408 bits)
    output reg key_expansion_done           // Sinal de finalização da expansão
);
    integer i;
    reg [31:0] temp;           // Variável temporária usada durante a expansão
    reg [31:0] w  [0:43];      // Chave expandida padrão (44 palavras de 32 bits)
    reg [31:0] dw [0:43];      // Chave expandida modificada (após InvMixColumns em rounds 1 a 9)

    // Entradas da S-box
    reg  [7:0] sb_in0, sb_in1, sb_in2, sb_in3;
    wire [7:0] sb_out0, sb_out1, sb_out2, sb_out3;  // Saídas da S-box (1 por byte)

    // Rcon - constantes usadas a cada múltiplo de Nk (4)
    wire [31:0] rcon [1:10];
    assign rcon[1]  = 32'h01000000;
    assign rcon[2]  = 32'h02000000;
    assign rcon[3]  = 32'h04000000;
    assign rcon[4]  = 32'h08000000;
    assign rcon[5]  = 32'h10000000;
    assign rcon[6]  = 32'h20000000;
    assign rcon[7]  = 32'h40000000;
    assign rcon[8]  = 32'h80000000;
    assign rcon[9]  = 32'h1b000000;
    assign rcon[10] = 32'h36000000;

    // Instancia 4 S-boxes paralelas, uma para cada byte
    sbox sbox0 (.endereco(sb_in0), .dado(sb_out0));
    sbox sbox1 (.endereco(sb_in1), .dado(sb_out1));
    sbox sbox2 (.endereco(sb_in2), .dado(sb_out2));
    sbox sbox3 (.endereco(sb_in3), .dado(sb_out3));

    // Vetores intermediários para armazenar as entradas e saídas dos módulos InvMixColumns
    // Mudança: usar reg ao invés de wire para permitir atribuições dentro do always
    reg [127:0] round_in [1:9];   // Entradas para os módulos InvMixColumns (1 por round intermediário)
    wire [127:0] round_out [1:9];  // Saídas dos módulos InvMixColumns

    // Instancia 9 módulos inverseMixColumns, um para cada round de 1 a 9
    genvar r;
    generate
        for (r = 1; r <= 9; r = r + 1) begin : invmix
            inverseMixColumns mix (
                .state_in(round_in[r]),
                .state_out(round_out[r])
            );
        end
    endgenerate

    // Função auxiliar RotWord: rotaciona 1 word de 32 bits 1 byte à esquerda
    function [31:0] rot_word;
        input [31:0] word;
        rot_word = {word[23:0], word[31:24]};
    endfunction

    // Bloco always combinacional — toda a expansão acontece de forma imediata
    always @(*) begin

        // Passo 1: copiar a chave original (key) para os primeiros 4 words (w[0] a w[3])
        w[0] = key[127:96];
        w[1] = key[95:64];
        w[2] = key[63:32];
        w[3] = key[31:0];

        // Passo 2: expansão da chave para w[4] até w[43]
        for (i = 4; i < 44; i = i + 1) begin
            temp = w[i - 1]; // pega a palavra anterior

            // A cada 4 palavras (múltiplo de Nk), aplica RotWord, SubWord e Rcon
            if (i % 4 == 0) begin
                temp = rot_word(temp); // rotaciona os bytes

                // Aplica S-box em cada byte da palavra (SubWord)
                sb_in0 = temp[31:24]; sb_in1 = temp[23:16];
                sb_in2 = temp[15:8];  sb_in3 = temp[7:0];
                #1; // espera propagação combinacional da S-box
                temp = {sb_out0, sb_out1, sb_out2, sb_out3};

                temp = temp ^ rcon[i / 4]; // adiciona constante de rodada
            end

            // Calcula a nova palavra com XOR da palavra Nk atrás
            w[i] = w[i - 4] ^ temp;
        end

        // Passo 3: inicia dw como uma cópia de w
        for (i = 0; i < 44; i = i + 1)
            dw[i] = w[i];

        // Prepara os blocos de entrada de 128 bits para os rounds intermediários (1 a 9)
        for (i = 1; i <= 9; i = i + 1) begin
            round_in[i] = {w[4*i], w[4*i+1], w[4*i+2], w[4*i+3]};
        end

        // Espera a propagação combinacional dos InvMixColumns
        #1;

        // Substitui os round keys intermediários por seus equivalentes com InvMixColumns
        for (i = 1; i <= 9; i = i + 1) begin
            {dw[4*i], dw[4*i+1], dw[4*i+2], dw[4*i+3]} = round_out[i];
        end

        // Passo 4: concatena todas as 11 round keys modificadas em 1 vetor de 1408 bits
        for (i = 0; i <= 10; i = i + 1)
            round_key_eic_flat[i*128 +: 128] = {dw[4*i], dw[4*i+1], dw[4*i+2], dw[4*i+3]};

        // Marca que a expansão foi concluída
        key_expansion_done = 1'b1;
    end

endmodule