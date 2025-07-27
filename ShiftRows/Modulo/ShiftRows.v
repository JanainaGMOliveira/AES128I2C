module shiftrows (
    input  [127:0] state_in,
    output [127:0] state_out,
    output         done_sr
);

  // Reorganização dos bytes conforme ShiftRows padrão AES
  assign state_out = {
    state_in[127:120], // b0
    state_in[87:80],   // b5
    state_in[47:40],   // b10
    state_in[7:0],     // b15

    state_in[95:88],   // b4
    state_in[55:48],   // b9
    state_in[15:8],    // b14
    state_in[103:96],  // b3

    state_in[63:56],   // b8
    state_in[23:16],   // b13
    state_in[111:104], // b2
    state_in[71:64],   // b7

    state_in[31:24],   // b12
    state_in[119:112], // b1
    state_in[79:72],   // b6
    state_in[39:32]    // b11
  };

  // Como é combinacional, a saída está sempre pronta
  assign done_sr = 1'b1;

endmodule

