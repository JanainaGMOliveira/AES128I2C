`timescale 1ns / 1ps

module i2c_slave_tb;

    // Inputs
	reg clk;
    reg rst;
    reg scl;
    reg sda_in;

    // Bidirectional SDA line com alta-impedancia forcada em 1
    tri1 sda;

    // Outputs
    wire start;
    wire bit_done;
	reg [3:0] data_bit_counter; // Contador para os bits dos dados
    wire [263:0] data_out; // Dado recebido
	wire [9:0] data_ready;

    // Internal variables
    reg [7:0] master_data; // Mestre envia dados para o escravo
    reg [263:0] data_128bits;
    reg [7:0] master_address = 8'b11010100; // Endereco do mestre (7 bits + bit R/W)
	reg sda_controle;
	 
	integer negedge_detected;

    integer i,j;

    // Instanciar o escravo I2C
    i2c_slave uut (
	    .clk(clk),
        .reset(rst),
		.scl(scl),
        .sda(sda),
        .data_out(data_out),
		.data_ready(data_ready),
        .start(start),
        .bit_done(bit_done)
    );

    // Controla a linha SDA
    assign sda = sda_controle ? 1'bz : sda_in;

    // Clock SCL
    always begin
        #100 scl = ~scl; // Frequencia do clock 5 MHz 
    end
	 
	 always begin
	     #5 clk = ~clk; // Frequencia do clock 100 MHz
    end

    initial begin
        // Inicializacao
        rst = 1;
		  clk = 1;
        scl = 0;
        data_128bits = 264'h00112233445566778899AABBCCDDEEFF_0123456789ABCDEF0123456789ABCDEF_00; // Dado a ser enviado para o escravo
		data_bit_counter = 0;
		sda_controle = 0;
		sda_in = 1;
		  
        // Libera o reset
        #15 rst = 0;

        // Simulacao do envio do endereco pelo mestre no modo escrita
        $display("Iniciando operacao de escrita...");

        // Enviar start condition (SDA vai de 1 para 0 com SCL = 1)
        @(posedge scl) #20 sda_in = 0;

        @(negedge scl);

        // Enviar endereco (7 bits + R/W = 0 para escrita)
        negedge_detected = 0; // Inicializar o sinal
 
        for (i = 7; i >= 0; i = i - 1) begin
            sda_in = master_address[i];
				// Aguardar uma das condicoes: borda de descida ou estado 2
				wait (uut.state == 2 || negedge_detected);
            // Resetar o sinal apos deteccao
            negedge_detected = 0;
        end

		// Libera o barramento (espera ACK do escravo)
		sda_controle = 1;
		wait (uut.state == 3); 
		sda_controle = 0;
        // Enviar dados (8 bits)
		negedge_detected = 0; // Inicializar o sinal
		  
        //128+128+8 = 264
        for (j = 263; j > 0; j = j - 8) 
        begin
            master_data = data_128bits[j-:8];
            wait (uut.state == 3);   
            for (i = 7; i >= 0; i = i - 1) 
            begin
                sda_in = master_data[i];  // Define bit de dados
        		// Aguardar uma das condicoes: borda de descida ou estado 2
                $display("Agora i = %0d e j = %0d", i, j);
        		wait (negedge_detected);
            
                // Resetar o sinal apos deteccao
                negedge_detected = 0;
            end
        	 // Libera o barramento (espera ACK do escravo)
        	sda_controle = 1;  
            wait (negedge_detected);
        	sda_controle = 0;
            // Enviar dados (8 bits)
        	negedge_detected = 0; // Inicializar o sinal
        end

        // Enviar stop condition (SDA vai de 0 para 1 com SCL = 1)
        @(negedge scl) sda_in = 0;
        @(posedge scl) #20 sda_in = 1;
        #100;

        $stop;
    end
	 
	 // Detectar a borda de descida de SCL
    always @(negedge scl) begin
        negedge_detected = 1;
    end
	 
endmodule
