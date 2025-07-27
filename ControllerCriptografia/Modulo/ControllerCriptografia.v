module controladorCriptografia(
	output [127:0] cifra,
	output done,	
	input [127:0] chave,
	input [127:0] palavra,
	input start,
	input rst,
	input clk
);
	reg [127:0] auxCifra;
	assign cifra = auxCifra;

	reg auxDone;
	assign done = auxDone;

	reg [2:0] currentState, nextState;
    parameter S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, S4 = 3'b100, S5 = 3'b101, S6 = 3'b110, S7 = 3'b111;
	
	wire [127:0] auxEstadoEntrada;
	wire [127:0] auxChaveEntrada;
	wire [127:0] estadoSaidaAddRoundKey;
	wire [127:0] estadoSaidaSubBytes;
	wire [127:0] estadoSaidaShiftRows;
	wire [127:0] estadoSaidaMixColumns;

	reg [4:0] contador;

	wire [1407:0] chavesExpandidasFlat;  // 11x128 bits da chave
	reg [127:0] chavesExpandidas [0:10]; // 11 grupos de chaves de 128 bits cada

	reg [127:0] estadoEntrada, chaveEntrada;

	assign auxEstadoEntrada = estadoEntrada;
	assign auxChaveEntrada = chaveEntrada;		

	expansion_key ek(auxChaveEntrada, chavesExpandidasFlat, );
	AddRoundKey   rk(auxEstadoEntrada, auxChaveEntrada, estadoSaidaAddRoundKey);
	subBytes      sb(auxEstadoEntrada, estadoSaidaSubBytes);
	shiftrows     sr(auxEstadoEntrada, estadoSaidaShiftRows, );
	mixColumns    mc(auxEstadoEntrada, estadoSaidaMixColumns);

	always @(posedge clk, posedge rst)
	begin
		if(rst)
		begin
			currentState <= S0;
		end
		else
		begin
			currentState <= nextState;
		end
	end
	
	always @(currentState, start)
	begin
		case (currentState)
			S0:
			begin
				estadoEntrada = 128'd0;
				chaveEntrada = 128'd0;
				auxDone = 1'b0;
				auxCifra = 128'd0;
				contador = 4'd0;
				
				if(start)
				begin
					nextState = S1;
				end
			end
			S1: // Expansion Key
			begin
				chaveEntrada = chave;	
				estadoEntrada = 128'd0;
				auxDone = 1'b0;
				auxCifra = 128'd0;
				contador = 4'd0;
				nextState = S2;	
			end
			S2: // AddRoundKey
			begin
				chavesExpandidas[10] = chavesExpandidasFlat[1407:1280];
				chavesExpandidas[9]  = chavesExpandidasFlat[1279:1152];
				chavesExpandidas[8]  = chavesExpandidasFlat[1151:1024];
				chavesExpandidas[7]  = chavesExpandidasFlat[1023:896];
				chavesExpandidas[6]  = chavesExpandidasFlat[895:768];
				chavesExpandidas[5]  = chavesExpandidasFlat[767:640];
				chavesExpandidas[4]  = chavesExpandidasFlat[639:512];
				chavesExpandidas[3]  = chavesExpandidasFlat[511:384];
				chavesExpandidas[2]  = chavesExpandidasFlat[383:256];
				chavesExpandidas[1]  = chavesExpandidasFlat[255:128];
				chavesExpandidas[0]  = chavesExpandidasFlat[127:0];

				estadoEntrada = palavra;
				chaveEntrada = chavesExpandidas[0];
				contador = 0;
				nextState = S3;
			end
			S3: // SubBytes
			begin
				contador = contador + 1;				
				estadoEntrada = estadoSaidaAddRoundKey;
				nextState = S4;
			end
			S4: // ShiftRows
			begin
				estadoEntrada = estadoSaidaSubBytes;
				if(contador == 4'd10)
				begin
					nextState = S6;
				end
				else
				begin
					nextState = S5;
				end	
			end
			S5: // MixColumns
			begin
				estadoEntrada = estadoSaidaShiftRows;
				nextState = S6;
			end
			S6: // AddRoundKey
			begin				
				chaveEntrada = chavesExpandidas[contador];

				if(contador == 4'd10)
				begin
					estadoEntrada = estadoSaidaShiftRows;
					nextState = S7;
				end
				else
				begin		
					estadoEntrada = estadoSaidaMixColumns;		
					nextState = S3;
				end	
			end
			S7: // Finalização
			begin
				auxCifra = estadoSaidaAddRoundKey;
				auxDone = 1'b1;

				nextState = S0;
			end
			default:
			begin
				nextState = S0;
			end
		endcase
	end
endmodule