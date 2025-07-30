module controller_decripto (
    output [127:0] palavra,
    output done,
	// output [127:0] auxEstadoEntrada,
	// output [127:0] auxChaveEntrada,
	// output [127:0] estadoSaidaAddRoundKey, 
	// output [127:0] estadoSaidaInvSubBytes, 
	// output [127:0] estadoSaidaInvShiftRows, 
	// output [127:0] estadoSaidaInvMixColumns,
	// output [2:0] estado,
    input  [127:0] chave,
    input  [127:0] cifra,
    input start,
    input rst,
    input clk
);

reg [127:0] auxPalavra;
assign palavra = auxPalavra;

reg auxDone;
assign done = auxDone;

reg [2:0] currentState, nextState;
// assign estado = currentState;

// 🔹 Estados da FSM
parameter IDLE                = 3'b000; //0
parameter LOAD_KEYS           = 3'b001; //1
parameter INIT_ADDROUNDKEY    = 3'b010; //2
parameter ROUND_INVSHIFTROWS  = 3'b011; //3
parameter ROUND_INVSUBBYTES      = 3'b100; //4
parameter ROUND_ADDROUNDKEY   = 3'b101; //5
parameter ROUND_INVMIXCOL     = 3'b110; //6
parameter FINISHED            = 3'b111; //7


// 🔹 Registradores internos

reg [4:0] contador;                // Contador de rodada (10 → 0)

wire [1407:0] chavesExpandidasFlat;  // 11x128 bits da chave
reg [127:0] chavesExpandidas [0:10]; // 11 grupos de chaves de 128 bits cada

//wire [127:0] auxEstadoEntrada, auxChaveEntrada;
reg [127:0] estadoEntrada, chaveEntrada;

assign auxEstadoEntrada = estadoEntrada;
assign auxChaveEntrada = chaveEntrada;

//wire [127:0] estadoSaidaAddRoundKey, estadoSaidaInvSubBytes, estadoSaidaInvShiftRows, estadoSaidaInvMixColumns;


// Instâncias

expansion_key     ek(auxChaveEntrada, chavesExpandidasFlat, );

AddRoundKey       rk(auxEstadoEntrada, auxChaveEntrada, estadoSaidaAddRoundKey);
inverseSubBytes   sb (auxEstadoEntrada, estadoSaidaInvSubBytes);
inv_shiftrows     sf (auxEstadoEntrada, estadoSaidaInvShiftRows, );
inverseMixColumns mc(auxEstadoEntrada, estadoSaidaInvMixColumns);

// 🔹 Transição de estados

	always @(posedge clk, posedge rst, posedge start)
	begin
		if(rst)
		begin
			currentState <= IDLE;
		end
		else
		begin
			currentState <= nextState;
		end
	end

always @(currentState, start)
	begin
		case (currentState)
			IDLE:
			begin
				estadoEntrada = 128'd0;
				chaveEntrada = 128'd0;
				auxDone = 1'b0;
				auxPalavra = 128'd0;
				contador = 4'd0;
				
				if(start)
				begin
					nextState = LOAD_KEYS;
				end
			end
			LOAD_KEYS: // Expansion Key
			begin
				chaveEntrada = chave;	
				estadoEntrada = 128'd0;
				auxDone = 1'b0;
				auxPalavra = 128'd0;
				contador = 4'd10;
				nextState = INIT_ADDROUNDKEY;	
			end
			INIT_ADDROUNDKEY: // AddRoundKey
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

				estadoEntrada = cifra;
				chaveEntrada = chavesExpandidas[10];
				nextState = ROUND_INVSHIFTROWS;
			end
			ROUND_INVSHIFTROWS: 
			begin
				if(contador == 4'd10)  // Init_ShiftRows
                begin				
					estadoEntrada = estadoSaidaAddRoundKey;
			    end
                else     // Intermediario_ShiftRows
                begin 
                	estadoEntrada = estadoSaidaInvMixColumns;
                end
				contador = contador - 1;				
				nextState = ROUND_INVSUBBYTES;
            end
            ROUND_INVSUBBYTES: // SubBytes
			begin
				estadoEntrada = estadoSaidaInvShiftRows;
				nextState = ROUND_ADDROUNDKEY;
					
			end
			ROUND_ADDROUNDKEY: // MixColumns
			begin
				chaveEntrada = chavesExpandidas[contador];
				estadoEntrada = estadoSaidaInvSubBytes;
                
                if(contador > 4'd0)
				begin
					nextState = ROUND_INVMIXCOL;
				end
				else
				begin					
					nextState = FINISHED;
				end	

			end
			ROUND_INVMIXCOL: // AddRoundKey
			begin
				estadoEntrada = estadoSaidaAddRoundKey;
				nextState = ROUND_INVSHIFTROWS;
			end	
                       
			FINISHED: // Finalização
			begin
				auxPalavra = estadoSaidaAddRoundKey;
				auxDone = 1'b1;
				// if(start)
				// begin
					nextState = IDLE;
				// end
			end
			default:
			begin
				nextState = IDLE;
			end
		endcase
	end
endmodule


