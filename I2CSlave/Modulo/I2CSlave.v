`timescale 1ns / 1ps

module i2c_slave (
    input wire clk,         // Clock do sistema
    input wire reset,       // Reset do sistema
    input wire scl,         // Linha de clock I2C
    inout wire sda,         // Linha de dados I2C
    output reg [263:0] data_out, // Dado recebido
    output reg [9:0] data_ready,     // Flag indicando dado recebido
    output reg start,          // Indica inicio e fim da transmissao
    output reg bit_done
);

    // Constantes
    localparam ADDRESS = 7'b1101010; // 6Ah
	 
    localparam IDLE = 3'b000;
    localparam ADDR = 3'b001;
    localparam ACK = 3'b010;
    localparam READ = 3'b011;
    localparam WAIT_STOP = 3'b100;
    localparam DONE = 3'b101;



    // Registradores internos
    reg [7:0] shift_reg;  // Registrador de deslocamento para leitura de dados
    reg [2:0] bit_count;  // Contador de bits
    reg [3:0] state;      // Estado atual da maquina de estados
    reg [3:0] next_state; // Proximo estado da maquina de estados
    reg sda_out;          // Controle de saida para SDA
    reg sda_drive;        // Define se o escravo controla diretamente a linha SDA
    reg scl_sync;         // Valor sincronizado de SCL
    reg sda_sync;         // Valor sincronizado de SDA
    reg scl_last;         // Estado anterior de SCL
    reg sda_last;         // Estado anterior de SDA
    reg byte_address;     // Sinaliza se o dado do SDA corresponde a um byte de address + comando W/R (ou seja primeiro byte)
    reg address_ok;       // Sinaliza que o Byte de address recebido contem o valor do address deste slave

    // Controle bidirecional da linha SDA
    assign sda = (sda_drive) ? sda_out : 1'bz;

    // Sincronizacao de SCL e SDA no clock do sistema
    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
        begin
            scl_sync <= 1;
            sda_sync <= 1;
            scl_last <= 1;
            sda_last <= 1;
        end 
        else 
        begin
            scl_sync <= scl;
            sda_sync <= sda;
            scl_last <= scl_sync;
            sda_last <= sda_sync;
        end
    end

    // // Deteccao de borda de start/stop
    // always @(posedge clk, posedge reset) 
    // begin

    //         if (!start && scl_sync && sda_last && !sda_sync) 
    //             start <= 1; // Condicao de start
    //         else if (start && scl_sync && !sda_last && sda_sync) 
    //             start <= 0; // Condicao de stop
    // end

    // verifica se a comunicaçao é com este endereço de slave
    // always @(posedge clk, posedge reset) 
    // begin

    //     if (shift_reg[7:0] == {ADDRESS,1'b0}) 
    //         address_ok <= 1; // Condicao de start
    //     else
    //         address_ok <= 0; // Condicao de stop
    // end
                           

     //Logica sequencial para o estado atual
    always @(posedge clk or posedge reset) 
    begin
        if (reset) 
            state <= IDLE;
        else 
            state <= next_state;
    end

    // Logica combinacional para o proximo estado
    always @(*) 
    begin
        // Estados padrao
        next_state = state;

        if (!start && state != WAIT_STOP && state != DONE) 
		    next_state = IDLE;
        else 
        begin
            case (state)

                IDLE: // Estado Inicial
                begin
                    if (start && scl_last && !scl_sync) 
                        next_state = ADDR;

                end

                ADDR: // Estado onde o ADDRESS foi recebido e iremos verificar se o ADDRESS é deste slave, para enviar um ACK ou retornar para IDLE.
                begin
                    if (scl_last && !scl_sync)
                        if (bit_count == 0) 
                            if (address_ok) 
                                next_state = ACK;
                            else
                                next_state = IDLE;
                end

                ACK: // Apos o envio do ACK, decidiremos se devemos receber mais dados, ou esperar pelo STOP
                begin
	                if (scl_last && !scl_sync)
                        if (byte_address)
                            if (address_ok) 
                                next_state = READ;
                            else
                                next_state = IDLE;
                        else if (data_ready < 10'd33) 
                            next_state = READ;
                        else if (data_ready == 10'd33)
                            next_state = WAIT_STOP;
                        else 
                            next_state = IDLE; // Endereco invalido
                end

                READ: // Apos recepçao de cada byte, mudaremos para o estado de ACK para enviar o ACK.
                begin
                    if (scl_last && !scl_sync) 
                        if (bit_count == 0) 
                            next_state = ACK;
                end

                WAIT_STOP: 
                begin  // Se o STOP for recebido, vai pra DONE, caso contrário vai para IDLE
                    if (scl_last && !scl_sync) 
                        if (!start)
                            next_state = DONE; 
                        else
                            next_state = IDLE; 
                end

                DONE: // Volta para IDLE.
                begin
                    if (scl_last && !scl_sync) 
                       next_state = IDLE; 
                end
                default: next_state = IDLE;
            endcase
	    end
    end

    // Logica combinacional e de saida
    always @(posedge clk or posedge reset) begin
        if (reset) 
        begin
            bit_count <= 7;
            shift_reg <= 8'b0;
            data_ready <= 0;
            data_out <= 0;
            sda_drive <= 0;
            sda_out <= 1;
            bit_done <=0;
            byte_address=0;
            address_ok<=0;
            start <=0;
        end 
        else 
        begin
            // Deteccao de borda de start/stop
            if (!start && scl_sync && sda_last && !sda_sync) 
                start <= 1; // Condicao de start
            else if (start && scl_sync && !sda_last && sda_sync) 
                start <= 0; // Condicao de stop

            // verifica se a comunicaçao é com este endereço de slave
            if (shift_reg[7:0] == {ADDRESS,1'b0}) 
                address_ok <= 1; // Condicao de start
            else
                address_ok <= 0; // Condicao de stop

            case (state)

                IDLE: 
                begin
                    bit_count <= 7;
                    shift_reg <= 8'b0;
                    data_ready <= 0;
                    data_out <= 0;
                    sda_drive <= 0;
                    sda_out <= 1;
                    bit_done <=0;
                    byte_address=0;
                    address_ok<=0;
                end

                ADDR: //Recebimento do primeiro Byte que é o byte de endereço + comando WR 
                begin
                    byte_address <= 1'b1;   // indica que o byte é o endereço
                    if (!scl_last && scl_sync) 
                        shift_reg[bit_count] <= sda_sync;
                    if (scl_last && !scl_sync) 
                        bit_count <= bit_count - 1'd1;

                end

                ACK: // Assumo controle da linha para envio do ACK
                begin
					sda_drive <= 1;
                    sda_out <= 0;
					if (scl_last && !scl_sync) 
                        data_out <= (data_out << 8) | shift_reg;
                end

                READ: //Faz a leitura bit a bit do byte de 1 byte de dado 
                begin
                    byte_address <= 1'b0;   // indica que o byte nao é o endereço
					sda_drive <= 0;
                    if (!scl_last && scl_sync) 
                    begin
                        shift_reg[bit_count] <= sda_sync;
                        if (bit_count == 0) 
                            data_ready <= data_ready + 1'd1;
                    end
					if (scl_last && !scl_sync) 
                        bit_count <= bit_count - 1'd1;
                end

                WAIT_STOP: //devolve a linha para o Master para poder receber o STOP 
                begin
                    sda_drive <= 0;
                end

                DONE: // Seta a flag bit_done para informar que todos os dados foram recebidos corretamente
                begin
                    if (!scl_last && scl_sync) 
                        bit_done = 1'b1;
                end
            endcase
        end
    end
endmodule
