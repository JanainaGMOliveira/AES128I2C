`timescale 1ns / 100ps

module tb_inverseMixColumns;
  reg [127:0] state_in;
  wire [127:0] state_out;
   reg done_invmix;             // saida apenas para efeito de visualização

  // Instanciando o módulo que será testado
  inverseMixColumns invmix (
    .state_in(state_in),
    .state_out(state_out)
  );

  /*  Testes usando o vetor is_row (state after InvShiftRows) em 9 rodadas AES FIPS 197  
       saida esperada vetor im_col (state after InvMixColumns) */

  initial begin
    
    done_invmix = 0;
    // Teste 1: round[ 1] 
    state_in = 128'hbd6e7c3df2b5779e0b61216e8b10b689;
    #20;
    done_invmix = 1;
    #5;
    $display("Entrada : %h", state_in);
    $display("Saída   : %h", state_out);

    // Teste 2: round[ 2]
    done_invmix = 0;
    state_in = 128'hfde3bad205e5d0d73547964ef1fe37f1;
    #20;
    done_invmix = 1;
    #5;
    $display("Entrada : %h", state_in);
    $display("Saída   : %h", state_out);

    // Teste 3: round[ 3]
    done_invmix = 0;
    state_in = 128'hd1876c0f79c4300ab45594add66ff41f;
     #20;
    done_invmix = 1;
    #5;
    $display("Entrada : %h", state_in);
    $display("Saída   : %h", state_out);

    // Teste 4: round[ 4]
    done_invmix = 0;
    state_in = 128'hc62fe109f75eedc3cc79395d84f9cf5d;
     #20;
    done_invmix = 1;
    #5;
    $display("Entrada : %h", state_in);
    $display("Saída   : %h", state_out);

    // Teste 5: round[ 5]
    done_invmix = 0;
    state_in = 128'hc81677bc9b7ac93b25027992b0261996;
     #20;
    done_invmix = 1;
    #5;
    $display("Entrada : %h", state_in);
    $display("Saída   : %h", state_out);

    // Teste 6: round[ 6]
    done_invmix = 0;
    state_in = 128'h247240236966b3fa6ed2753288425b6c;
     #20;
    done_invmix = 1;
    #5;
    $display("\nEntrada : %h", state_in);
    $display("Saída   : %h", state_out);

    // Teste 7: round[ 7]
    done_invmix = 0;
    state_in = 128'hfa636a2825b339c940668a3157244d17;
     #20;
    done_invmix = 1;
    #5;
    $display("\nEntrada : %h", state_in);
    $display("Saída   : %h", state_out);

    // Teste 8: round[ 8]
    done_invmix = 0;
    state_in = 128'h4915598f55e5d7a0daca94fa1f0a63f7;
     #20;
    done_invmix = 1;
    #5;
    $display("\nEntrada : %h", state_in);
    $display("Saída   : %h", state_out);

    // Teste 9: round[ 9]
    done_invmix = 0;
    state_in = 128'h89d810e8855ace682d1843d8cb128fe4;
     #20;
    done_invmix = 1;
    #5;
    $display("\nEntrada : %h", state_in);
    $display("Saída   : %h", state_out);

    // Teste 10: Todos os bits em 0
    done_invmix = 0;
    state_in = 128'h00000000_00000000_00000000_00000000;
     #20;
    done_invmix = 1;
    #5;
    $display("\nEntrada : %h", state_in);
    $display("Saída   : %h", state_out);

    // Teste 11: Todos os bits em 1
    done_invmix = 0;
    state_in = 128'hFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF;
     #20;
    done_invmix = 1;
    #5;
    $display("\nEntrada : %h", state_in);
    $display("Saída   : %h", state_out);

    
    $stop;
  end

endmodule
