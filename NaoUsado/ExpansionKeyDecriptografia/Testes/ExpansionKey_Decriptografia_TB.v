`timescale 1ns / 1ps

// Expansão de chave AES-128 para decriptografia (Inverse Cipher - FIPS 197)
// Gera round keys em ordem invertida: de W[40–43] até W[0–3]

module expansion_key_inverse_cipher (
    input  [127:0] key,                    // Chave original de 128 bits
    output reg [1407:0] round_keys_flat,  // Round keys invertidas (11 × 128 bits)
    output reg key_expansion_done
);

    integer i;
    reg [31:0] temp;
    reg [31:0] w [0:43];  // Vetor W de 44 palavras de 32 bits (AES-128)

    // S-box entradas e saídas
    reg  [7:0] sb_in0, sb_in1, sb_in2, sb_in3;
    wire [7:0] sb_out0, sb_out1, sb_out2, sb_out3;

    // Rcon - constantes da FIPS 197
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

    // Instâncias das S-boxes
    sbox sbox0 (.endereco(sb_in0), .dado(sb_out0));
    sbox sbox1 (.endereco(sb_in1), .dado(sb_out1));
    sbox sbox2 (.endereco(sb_in2), .dado(sb_out2));
    sbox sbox3 (.endereco(sb_in3), .dado(sb_out3));

    // Função RotWord
    function [31:0] rot_word;
        input [31:0] word;
        begin
            rot_word = {word[23:0], word[31:24]};
        end
    endfunction

    always @(*) begin
        // Etapa 1: copiar chave original para w[0] a w[3]
        w[0] = key[127:96];
        w[1] = key[95:64];
        w[2] = key[63:32];
        w[3] = key[31:0];

        // Etapa 2: gerar w[4] até w[43]
        for (i = 4; i < 44; i = i + 1) begin
            temp = w[i - 1];
            if (i % 4 == 0) begin
                temp = rot_word(temp);

                // SubWord com 4 S-boxes
                sb_in0 = temp[31:24];
                sb_in1 = temp[23:16];
                sb_in2 = temp[15:8];
                sb_in3 = temp[7:0];
                #1; // delay simbólico (modelagem comportamental)

                temp = {sb_out0, sb_out1, sb_out2, sb_out3};
                temp = temp ^ rcon[i / 4];
            end
            w[i] = w[i - 4] ^ temp;
        end

        // Etapa 3: montar round_keys_flat com chaves em ordem invertida
        for (i = 0; i <= 10; i = i + 1) begin
            round_keys_flat[i*128 +: 128] = {
                w[40 - 4*i], w[41 - 4*i], w[42 - 4*i], w[43 - 4*i]
            };
        end

        key_expansion_done = 1'b1;
    end

endmodule
