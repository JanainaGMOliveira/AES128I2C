module tb_sbox;
  reg [7:0] endereco;
  wire [7:0] dado;


  sbox uut (
    .endereco(endereco),
    .dado(dado)
  );

 // teste de todos os 256 valores de 8 bits da tabela sbox

  integer i;
  initial begin
    for (i = 0; i < 256; i = i + 1) begin
      endereco = i[7:0];
      #5;
      $display("Input: %h => Output: %h", endereco, dado);
    end
    
    $stop;
  end
endmodule
