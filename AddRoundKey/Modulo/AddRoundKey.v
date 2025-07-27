module AddRoundKey (
    input  wire [127:0] state_in, // Matriz de estado antes da round key
    input  wire [127:0] round_key, // Subchave da rodada
    output wire [127:0] state_out // Matriz de estado depois do XOR   
);
    assign state_out       = state_in ^ round_key;
endmodule
