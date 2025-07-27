

`timescale 1ns / 100ps

module tb_inverseSubBytes;

  reg [127:0] in;
  wire [127:0] out;

  inverseSubBytes invsub (
    .in(in),
    .out(out)
  );

/*  Testes usando o vetor is_row (state after InvShiftRow) em 9 rodadas AES FIPS 197  
       saida esperada vetor is_box (state after InvSubBytes) */

  initial begin
    $display("== Teste InvSubBytes ==");

    
    // Teste 1: round[ 1] 

    in = 128'h7a9f102789d5f50b2beffd9f3dca4ea7;
    #10;
    $display("Entrada : %h", in);
    $display("Saída   : %h", out);

    // Teste 2: round[ 2]
    
    in = 128'h5411f4b56bd9700e96a0902fa1bb9aa1;
    #10;
    $display("Entrada : %h", in);
    $display("Saída   : %h", out);

    // Teste 3: round[ 3]

    in = 128'h3e175076b61c04678dfc2295f6a8bfc0;
    #10;
    $display("Entrada : %h", in);
    $display("Saída   : %h", out);

    // Teste 4: round[ 4]
    
    in = 128'hb415f8016858552e4bb6124c5f998a4c;
    #10;
    $display("Entrada : %h", in);
    $display("Saída   : %h", out);

    // Teste 5: round[ 5]
    
    in = 128'he847f56514dadde23f77b64fe7f7d490;
    #10;
    $display("Entrada : %h", in);
    $display("Saída   : %h", out);

    // Teste 6: round[ 6]
    
    in = 128'h36400926f9336d2d9fb59d23c42c3950;
     #10;
    $display("Entrada : %h", in);
    $display("Saída   : %h", out);

    // Teste 7: round[ 7]
    
    in = 128'h2dfb02343f6d12dd09337ec75b36e3f0;
     #10;
    $display("Entrada : %h", in);
    $display("Saída   : %h", out);

    // Teste 8: round[ 8]
    
    in = 128'h3b59cb73fcd90ee05774222dc067fb68;
     #10;
     $display("Entrada : %h", in);
    $display("Saída   : %h", out);

    // Teste 9: round[ 9]
    
    in = 128'ha761ca9b97be8b45d8ad1a611fc97369 ;
     #10;
    $display("Entrada : %h", in);
    $display("Saída   : %h", out);


    // Teste 10: round[ 10]
    
    in = 128'h63cab7040953d051cd60e0e7ba70e18c;
     #10;
     $display("Entrada : %h", in);
    $display("Saída   : %h", out);

    // Teste 11: Todos os bits em 0    
    in = 128'h00000000_00000000_00000000_00000000;
     #10;
    $display("Entrada : %h", in);
    $display("Saída   : %h", out);

    // Teste 12: Todos os bits em 1
    
    in = 128'hFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF;
     #10;
    $display("Entrada : %h", in);
    $display("Saída   : %h", out);
    $stop;
  end

endmodule
