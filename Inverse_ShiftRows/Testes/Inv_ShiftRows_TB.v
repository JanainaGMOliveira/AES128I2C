`timescale 1ns / 1ps

module tb_inv_shiftrows;

  // Sinais de teste
  reg  [127:0] state_in;
  wire [127:0] state_out;
  wire         done_sr;
  reg  [127:0] expected;
  integer i;
  integer j;

  // Instanciação do módulo combinacional
  inv_shiftrows uut (
    .state_in(state_in),
    .state_out(state_out),
    .done_sr(done_sr)
  );

  // Modelo de referência para InvShiftRows
  task inv_shiftrows_model(input [127:0] din, output [127:0] dout);
    reg [7:0] b [0:15]; // b = byte na matrix state
    begin
      for (j = 0; j < 16; j = j + 1)
        b[j] = din[127 - j*8 -: 8];

      dout = {
        b[0],  b[13],  b[10], b[7],
        b[4],  b[1],  b[14], b[11],
        b[8],  b[5], b[2],  b[15],
        b[12], b[9],  b[6],  b[3]
      };
    end
  endtask

  initial begin
    $display("🔎 Iniciando testes para inv_shiftrows...");

    for (i = 0; i < 10; i = i + 1) begin
      
      state_in = $random; // Gera entrada aleatória
      inv_shiftrows_model(state_in, expected); // Saída esperada
      #2;

      // Verificação de saída
      $display("🔸 Teste %0d", i);
      $display("state_in   = %h", state_in);
      $display("esperado   = %h", expected);
      $display("obtido     = %h", state_out);
      $display("done_sr = %b", done_sr);

      if (state_out !== expected || done_sr !== 1'b1) begin
        $display("❌ Falha: resultado incorreto ou done_sr não ativo.\n");
      end else begin
        $display("✅ Sucesso: resultado correto e done_sr ativo.\n");
      end

    end

    $display("🏁 Testbench de inv_shiftrows finalizada.");
    $stop;
  end

endmodule
