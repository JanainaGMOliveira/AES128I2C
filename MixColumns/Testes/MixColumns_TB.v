

`timescale 1ns / 100ps

module tb_mixColumns;

  // Entradas e saídas
  reg  [127:0] state_in;
  wire [127:0] state_out;
  reg done_mix;             // saida apenas para efeito de visualização

  // Instancia o modulo 
  mixColumns mix (
    .state_in(state_in),
    .state_out(state_out)
  );

   /*  Testes usando o vetor s_row (state after ShiftRow) em 9 rodadas AES FIPS 197  
       saida esperada vetor m_col (state after MixColumns) */

  initial begin
    $display("===== Teste do módulo MixColumns =====");
    done_mix = 0;
    // Teste 1: round[ 1] 
    state_in = 128'h6353e08c0960e104cd70b751bacad0e7;
    #20;
    done_mix = 1;
    #5;
    $display("Entrada : %h", state_in);
    $display("Saída   : %h", state_out);

    // Teste 2: round[ 2]
    done_mix = 0;
    state_in = 128'ha7be1a6997ad739bd8c9ca451f618b61;
    #20;
    done_mix = 1;
    #5;
    $display("Entrada : %h", state_in);
    $display("Saída   : %h", state_out);

    // Teste 3: round[ 3]
    done_mix = 0;
    state_in = 128'h3bd92268fc74fb735767cbe0c0590e2d;
     #20;
    done_mix = 1;
    #5;
    $display("Entrada : %h", state_in);
    $display("Saída   : %h", state_out);

    // Teste 4: round[ 4]
    done_mix = 0;
    state_in = 128'h2d6d7ef03f33e334093602dd5bfb12c7;
     #20;
    done_mix = 1;
    #5;
    $display("Entrada : %h", state_in);
    $display("Saída   : %h", state_out);

    // Teste 5: round[ 5]
    done_mix = 0;
    state_in = 128'h36339d50f9b539269f2c092dc4406d23;
     #20;
    done_mix = 1;
    #5;
    $display("Entrada : %h", state_in);
    $display("Saída   : %h", state_out);

    // Teste 6: round[ 6]
    done_mix = 0;
    state_in = 128'he8dab6901477d4653ff7f5e2e747dd4f;
     #20;
    done_mix = 1;
    #5;
    $display("\nEntrada : %h", state_in);
    $display("Saída   : %h", state_out);

    // Teste 7: round[ 7]
    done_mix = 0;
    state_in = 128'hb458124c68b68a014b99f82e5f15554c;
     #20;
    done_mix = 1;
    #5;
    $display("\nEntrada : %h", state_in);
    $display("Saída   : %h", state_out);

    // Teste 8: round[ 8]
    done_mix = 0;
    state_in = 128'h3e1c22c0b6fcbf768da85067f6170495;
     #20;
    done_mix = 1;
    #5;
    $display("\nEntrada : %h", state_in);
    $display("Saída   : %h", state_out);

    // Teste 9: round[ 9]
    done_mix = 0;
    state_in = 128'h54d990a16ba09ab596bbf40ea111702f;
     #20;
    done_mix = 1;
    #5;
    $display("\nEntrada : %h", state_in);
    $display("Saída   : %h", state_out);

    // Teste 10: Todos os bits em 0
    done_mix = 0;
    state_in = 128'h00000000_00000000_00000000_00000000;
     #20;
    done_mix = 1;
    #5;
    $display("\nEntrada : %h", state_in);
    $display("Saída   : %h", state_out);

    // Teste 11: Todos os bits em 1
    done_mix = 0;
    state_in = 128'hFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF;
     #20;
    done_mix = 1;
    #5;
    $display("\nEntrada : %h", state_in);
    $display("Saída   : %h", state_out);

    
    $stop;
  end

endmodule