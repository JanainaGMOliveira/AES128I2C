module tb_inv_sbox;
  reg [7:0] data_in;
  wire [7:0] data_out;


  inv_sbox uut (
    .data_in(data_in),
    .data_out(data_out)
  );

// teste de todos os 256 valores de 8 bits da tabela invsbox

  integer i;
  initial begin
    for (i = 0; i < 256; i = i + 1) begin
      data_in = i[7:0];
      #5;
      $display("Input: %h => Output: %h", data_in, data_out);
    end
    
    $stop;
  end
endmodule
