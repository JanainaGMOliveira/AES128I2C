

module inverseMixColumns(state_in,state_out);
  input [127:0] state_in;
  output [127:0] state_out;

  /*
  A multiplicação por {02} é implementada a nível de byte como um deslocamento
   para a esquerda e um subsequente XOR condicional bit a bit com {1b}, onde o XOR
  com {1b} é feito se x[7]= 1. A multiplicação por potências maiores de x pode ser
  implementada pela aplicação repetida da multiplicação por 2.
  */

  //Esta função multiplica por {02} n-vezes
  function[7:0] multiply(input [7:0]x,input integer n);
    integer i;
    begin
      for(i=0;i<n;i=i+1)
      begin
        if(x[7] == 1)
          x = ((x << 1) ^ 8'h1b);
        else
          x = x << 1;
      end
      multiply=x;
    end

  endfunction


  /*
  	A multiplicação por {0e} é feita por:
    (multiply(x, 3): Executa 0x02(xtime) três vezes, o que equivale à multiplicação por 0x08) xor
    (multiplicar por {02} 2 vezes, que é equivalente à multiplicação por {04}) xor
    (multiplicar por {02})
    de forma que 8+4+2= e. Onde xor é a adição de elementos em corpos finitos.
    0x0E = (x·8) ⊕ (x·4) ⊕ (x·2)  
    multiply(x, 3): Executa 0x02(xtime) três vezes, o que equivale à multiplicação por 0x08.
*/
  function [7:0] mb0e; //multiplica por {0e}
    input [7:0] x;
    begin
      mb0e=multiply(x,3) ^ multiply(x,2)^ multiply(x,1);
    end
  endfunction

  /*
  	A multiplicação por {0d} é feita por:
    (multiplicar por {02} 3 vezes, que é equivalente à multiplicação por {08}) xor
    (multiplicar por {02} 2 vezes, que é equivalente à multiplicação por {04}) xor
    (o x original)
    de forma que 8+4+1= d. Onde xor é a adição de elementos em corpos finitos.
  */
  function [7:0] mb0d; //multiplica por {0d}
    input [7:0] x;
    begin
      mb0d=multiply(x,3) ^ multiply(x,2)^ x;
    end
  endfunction


  /*
  	A multiplicação por {0b} é feita por:
    (multiplicar por {02} 3 vezes, que é equivalente à multiplicação por {08}) xor
    (multiplicar por {02}) xor (o x original)
    de forma que 8+2+1= b. Onde xor é a adição de elementos em corpos finitos.
  */

  function [7:0] mb0b;  //multiplica por {0b}
    input [7:0] x;
    begin
      mb0b=multiply(x,3) ^ multiply(x,1)^ x;
    end
  endfunction
  /*
  	A multiplicação por {09} é feita por:
    (multiplicar por {02} 3 vezes, que é equivalente à multiplicação por {08}) xor (o x original)
    de forma que 8+1= 9. Onde xor é a adição de elementos em corpos finitos.
  */

  function [7:0] mb09; //multiplica por {09}
    input [7:0] x;
    begin
      mb09=multiply(x,3) ^  x;
    end
  endfunction

  genvar i;

  generate
    for(i=0;i< 4;i=i+1)
    begin : m_col

      assign state_out[(i*32 + 24)+:8]= mb0e(state_in[(i*32 + 24)+:8]) ^ // S'0 = e.S0^
                                        mb0b(state_in[(i*32 + 16)+:8]) ^ // b.S1^
                                        mb0d(state_in[(i*32 + 8)+:8]) ^  // d.S2^
                                        mb09(state_in[i*32+:8]);         // 9.S3

      assign state_out[(i*32 + 16)+:8]= mb09(state_in[(i*32 + 24)+:8]) ^ 
                                        mb0e(state_in[(i*32 + 16)+:8]) ^ 
                                        mb0b(state_in[(i*32 + 8)+:8]) ^ 
                                        mb0d(state_in[i*32+:8]);

      assign state_out[(i*32 + 8)+:8]= mb0d(state_in[(i*32 + 24)+:8]) ^ 
                                      mb09(state_in[(i*32 + 16)+:8]) ^ 
                                      mb0e(state_in[(i*32 + 8)+:8]) ^ 
                                      mb0b(state_in[i*32+:8]);

      assign state_out[i*32+:8]= mb0b(state_in[(i*32 + 24)+:8]) ^ 
                                  mb0d(state_in[(i*32 + 16)+:8]) ^ 
                                  mb09(state_in[(i*32 + 8)+:8]) ^ 
                                  mb0e(state_in[i*32+:8]);

    end

  endgenerate


endmodule

/*
    S0 = state_in[(i*32 + 24) +: 8] (Byte mais significativo da palavra de 32 bits)
    S1 = state_in[(i*32 + 16) +: 8]
    S2 = state_in[(i*32 + 8) +: 8]
    S3 = state_in[(i*32 + 0) +: 8] (Byte menos significativo da palavra de 32 bits)


    Equacão:
    S'0 = (0E•S0) ⊕ (0B•S1) ⊕ (0D•S2) ⊕ (09•S3)
    S'1 = (09•S0) ⊕ (0E•S1) ⊕ (0B•S2) ⊕ (0D•S3)
    S'2 = (0D•S0) ⊕ (09•S1) ⊕ (0E•S2) ⊕ (0B•S3)
    S'3 = (0B•S0) ⊕ (0D•S1) ⊕ (09•S2) ⊕ (0E•S3)

*/