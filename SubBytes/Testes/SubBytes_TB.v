
`timescale 1ns / 100ps

module tb_subBytes;

  reg [127:0] in;
  wire [127:0] out;

  subBytes sub (
    .in(in),
    .out(out)
  );

/*  Testes usando o vetor start (state at start of round[r]) em 10 rodadas AES FIPS 197  
       saida esperada vetor s_box (state after SubBytes) */

  initial begin
    $display("== Teste SubBytes ==");

    
    // Teste 1: round[ 1] 

    in = 128'h00102030405060708090a0b0c0d0e0f0;
    #10;
    $display("Entrada : %h", in);
    $display("Saída   : %h", out);

    // Teste 2: round[ 2]
    
    in = 128'h89d810e8855ace682d1843d8cb128fe4;
    #10;
    $display("Entrada : %h", in);
    $display("Saída   : %h", out);

    // Teste 3: round[ 3]

    in = 128'h4915598f55e5d7a0daca94fa1f0a63f7;
    #10;
    $display("Entrada : %h", in);
    $display("Saída   : %h", out);

    // Teste 4: round[ 4]
    
    in = 128'hfa636a2825b339c940668a3157244d17;
    #10;
    $display("Entrada : %h", in);
    $display("Saída   : %h", out);

    // Teste 5: round[ 5]
    
    in = 128'h247240236966b3fa6ed2753288425b6c;
    #10;
    $display("Entrada : %h", in);
    $display("Saída   : %h", out);

    // Teste 6: round[ 6]
    
    in = 128'hc81677bc9b7ac93b25027992b0261996;
     #10;
    $display("Entrada : %h", in);
    $display("Saída   : %h", out);

    // Teste 7: round[ 7]
    
    in = 128'hc62fe109f75eedc3cc79395d84f9cf5d;
     #10;
    $display("Entrada : %h", in);
    $display("Saída   : %h", out);

    // Teste 8: round[ 8]
    
    in = 128'hd1876c0f79c4300ab45594add66ff41f;
     #10;
     $display("Entrada : %h", in);
    $display("Saída   : %h", out);

    // Teste 9: round[ 9]
    
    in = 128'hfde3bad205e5d0d73547964ef1fe37f1 ;
     #10;
    $display("Entrada : %h", in);
    $display("Saída   : %h", out);


    // Teste 10: round[ 10]
    
    in = 128'hbd6e7c3df2b5779e0b61216e8b10b689;
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

