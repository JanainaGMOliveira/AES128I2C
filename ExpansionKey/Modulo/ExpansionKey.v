`timescale 1ns / 1ps

module expansion_key (
    input  [127:0] key, // chave original de 128 bits
    output reg [1407:0] round_key_flat,  // 11 round keys de 128 bits (11 × 128 = 1408 bits)
    output reg key_expansion_done // flag que indica que a expansão está concluída
);

    integer i; // índice para o laço for
    reg [31:0] temp; // variável temporária usada nos cálculos
    reg [31:0] w [0:43];  // vetor que guardas as 44 palavras de 32 bits para AES-128

    // S-box entradas e saídas, onde cada byte de temp será passado por uma instância da S-box
	// com 4 entradas e 4 saídas
    reg  [7:0] sb_in0, sb_in1, sb_in2, sb_in3;
    wire [7:0] sb_out0, sb_out1, sb_out2, sb_out3;

    // Rcon: constantes para expansão, que são fixas e obtidas na FIPS 197
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

    // Instâncias das S-Boxes
    sbox sbox0 (.endereco(sb_in0), .dado(sb_out0));
    sbox sbox1 (.endereco(sb_in1), .dado(sb_out1));
    sbox sbox2 (.endereco(sb_in2), .dado(sb_out2));
    sbox sbox3 (.endereco(sb_in3), .dado(sb_out3));

    // Função RotWord que rotaciona uma palavra de 32 bits (movendo o 1º byte para o final)
    function [31:0] rot_word;
        input [31:0] word;
        begin
            rot_word = {word[23:0], word[31:24]};
        end
    endfunction

    always @(*) begin
        // Inicializa as 4 primeiras palavras com a chave original
		// Os 128 bits da chave inicial em 4 palavras de 32 bits
        w[0] = key[127:96];
        w[1] = key[95:64];
        w[2] = key[63:32];
        w[3] = key[31:0];

        // Expansão da chave (gera W[4] a W[43])
        for (i = 4; i < 44; i = i + 1) begin
            temp = w[i - 1];

            if (i % 4 == 0) begin
                // RotWord
                temp = rot_word(temp);

                // SubWord (aplica S-box byte a byte)
                sb_in0 = temp[31:24];
                sb_in1 = temp[23:16];
                sb_in2 = temp[15:8];
                sb_in3 = temp[7:0];
                #1; // Delay simbólico para simulação
                temp = {sb_out0, sb_out1, sb_out2, sb_out3};

                // XOR com Rcon
                temp = temp ^ rcon[i / 4];
            end
			// Xor quuando i não é múltiplo de 4
            w[i] = w[i - 4] ^ temp;
        end

        // Monta os 11 round keys (cada um com 128 bits), facilita a visualização, e 
		// armazena as 11 chaves de uma vez
		// facilita o acesso a cada subchave com slicing
		// exemplo:
		// i = 0 → round_key_flat[127:0] recebe {w[0], w[1], w[2], w[3]}
		// i = 1 → round_key_flat[255:128] recebe {w[4], w[5], w[6], w[7]} e etc
        for (i = 0; i <= 10; i = i + 1) begin
            round_key_flat[i*128 +: 128] = {w[4*i], w[4*i+1], w[4*i+2], w[4*i+3]};
        end
		// Sinalizador, flag
        key_expansion_done = 1'b1;
    end

endmodule
