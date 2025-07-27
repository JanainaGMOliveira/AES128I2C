module top_i2c_aes128(
    output [127:0] saida,
    output done,
    inout sda,
    input scl,
    input clock,
    input reset
);

    reg [1:0] currentState;
    parameter S0 = 2'b00, S1 = 2'b01, S2 = 2'b10;

    wire [127:0] entrada, chave, outCripto, outDecripto;
    
    wire operacao; // 0: cripto, 1: decripto
    wire startI2C;
    wire doneI2C, doneCripto, doneDecripto;

    reg enableCripto, enableDecripto;

    wire [263:0] auxI2Cout;
    assign entrada = auxI2Cout[263:136];
    assign chave = auxI2Cout[135:8];
    assign operacao = auxI2Cout[0];

    reg [127:0] auxSaida;
    assign saida = auxSaida;

    reg auxDone;
    assign done = auxDone;

    i2c_slave               i2c(.data_out(auxI2Cout), .bit_done(doneI2C), .start(startI2C), .scl(scl), .sda(sda), .reset(reset), .clk(clock));
    controladorCriptografia cripto(.cifra(outCripto), .done(doneCripto), .chave(chave), .palavra(entrada), .start(enableCripto), .rst(reset), .clk(clock));
    controller_decripto     decripto(.palavra(outDecripto), .done(doneDecripto), .chave(chave), .cifra(entrada), .start(enableDecripto), .rst(reset), .clk(clock));

    always @(posedge clock, posedge reset)
	begin
        if(reset)
		begin
			currentState <= S0;
		end
		else
        begin
            case (currentState)
                S0: // Reset state
                begin
                    enableCripto = 1'b0;
                    enableDecripto = 1'b0;
                    auxDone = 1'b0;
                    
                    if(doneI2C)
                    begin
                        enableCripto = !operacao;
                        enableDecripto = operacao;
                        currentState = S1;
                    end
                end
                S1: // Calculation state
                begin               
                    if(enableCripto && doneCripto)
                    begin
                        enableCripto = 1'b0;
                        auxSaida = outCripto;
                        currentState = S2;
                    end
                    else if (enableDecripto && doneDecripto) 
                    begin
                        enableDecripto = 1'b0;
                        auxSaida = outDecripto;
                        currentState = S2;
                    end
                    else
                    begin
                        currentState = S1;
                    end
                end
                S2: // Result state
                begin             
                    auxDone = 1'b1;

                    if(!startI2C)
                    begin
                        currentState = S0;
                    end
                    else
                    begin
                        currentState = S1;
                    end
                end
            endcase
        end
    end
endmodule