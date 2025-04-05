module Coprocessor (
	input wire clk,          		// Sinal de clock de entrada
	input wire reset,          	// Sinal de reset para reiniciar a operação
	input wire button,       		// Botão para controlar a execução do módulo
	input wire test,
	input wire [2:0] op_code,    // Código de operação (para determinar a operação a ser executada)
	output wire overflow,    		// Indicador de overflow
	output reg [6:0] Display0,
	output reg [6:0] Display1,
	output [4:0] LEDsContador
);	
	
	// Declaração das variáveis de controle
	reg [6:0] mem_addr;      							// Endereço de memória (7 bits)
	reg mem_we, start_deter, clk_1_segundo = 0; 	// Controle de escrita na memória e sinal de início do cálculo
	reg [15:0] mem_data_in;  							// Dados a serem escritos na memória (16 bits)
	reg [2:0] state = 0;         						// Estado do sistema (2 bits)
	reg [6:0] Counter_wait = 0;  						// Contador para temporização e delays (7 bits)
	reg [4:0] index = 0;         						// Índice para acessar elementos das matrizes
	reg [7:0] scalar = 8'd3;        					// Escalar para multiplicação das matrizes
	wire [15:0] mem_data_out; 							// Dados lidos da memória (16 bits)
	wire rst;
	reg [25:0] counter = 0;

	// Teste no display
	reg [4:0] index_display = 0;
	reg [15:0] value_display;
	reg [3:0] digit = 0;

	// Matrizes de teste e resultados
	reg signed [7:0] matrix_a_Send [0:24];   // Matriz A de entrada (valores de 8 bits com sinal)
	reg signed [7:0] matrix_b_Send [0:24];   // Matriz B de entrada (valores de 8 bits com sinal)
	reg [199:0] matrix_a_Receive;    		  // Matriz A para processamento (199 bits)
	reg [199:0] matrix_b_Receive;            // Matriz B para processamento (199 bits)
	reg signed [7:0] matrix_Result [0:24];   // Resultado da multiplicação das matrizes
	wire [199:0] matrix_out;          // Resultado final do coprocessador
	 
	// Definindo estados da FSM
	localparam S0_INIT_WRITE   = 3'b000;
	localparam S1_WAIT_WRITE   = 3'b001;
	localparam S2_READ_MEM     = 3'b010;
	localparam S3_WAIT_READ    = 3'b011;
	localparam S4_PROCESS      = 3'b100;
	localparam S5_WAIT_PROCESS = 3'b101;
	localparam S6_WRITE_RESULT = 3'b110;
	localparam S7_DONE         = 3'b111;


	// Instancia o coprocessador que executa as operações de matrizes
	Alu uut (
		.op_code(op_code),
		.matrix_a(matrix_a_Receive),
		.matrix_b(matrix_b_Receive),
		.scalar(scalar),
		.overflow(overflow),
		.result_final(matrix_out),
		.clk(clk),          						// Clock para a operação sequencial
		.rst(rst),          						// Reset para reiniciar o cálculo da determinante
		.start(start_deter) 						// Sinal para iniciar o cálculo do determinante
	);

	// Instancia a memória para armazenar dados temporários
	MemoryBlock memory (
		.address(mem_addr),  						// Endereço de memória
		.clock(clk),         						// Clock para sincronizar com a memória
		.data(mem_data_in),  						// Dados a serem escritos
		.wren(mem_we),       						// Controle de escrita na memória
		.q(mem_data_out)     						// Dados lidos da memória
	);

	// Inicializa as matrizes de teste
	/*initial begin
		// Definir valores manualmente para matrix_a_Send
		matrix_a_Send[0]  = 2;  matrix_a_Send[1]  = 32;  matrix_a_Send[2]  = 12;  matrix_a_Send[3]  = 6;   matrix_a_Send[4]  = 10;
		matrix_a_Send[5]  = 5;  matrix_a_Send[6]  = 18;  matrix_a_Send[7]  = 39;  matrix_a_Send[8]  = 7;   matrix_a_Send[9]  = 17;
		matrix_a_Send[10] = 4;  matrix_a_Send[11] = 69;  matrix_a_Send[12] = 26;  matrix_a_Send[13] = 10;  matrix_a_Send[14] = 42;
		matrix_a_Send[15] = 3;  matrix_a_Send[16] = 9;   matrix_a_Send[17] = 16;  matrix_a_Send[18] = 24;  matrix_a_Send[19] = 32;
		matrix_a_Send[20] = 8;  matrix_a_Send[21] = 3;   matrix_a_Send[22] = 25;  matrix_a_Send[23] = 3;   matrix_a_Send[24] = 27;

		// Definir valores manualmente para matrix_b_Send
		matrix_b_Send[0]  = 8;  matrix_b_Send[1]  = 14;  matrix_b_Send[2]  = 94;  matrix_b_Send[3]  = 54;  matrix_b_Send[4]  = 61;
		matrix_b_Send[5]  = 76; matrix_b_Send[6]  = 1;   matrix_b_Send[7]  = 0;   matrix_b_Send[8]  = 43;  matrix_b_Send[9]  = 18;
		matrix_b_Send[10] = 41; matrix_b_Send[11] = 38;  matrix_b_Send[12] = 67;  matrix_b_Send[13] = 22;  matrix_b_Send[14] = 9;
		matrix_b_Send[15] = 6;  matrix_b_Send[16] = 8;   matrix_b_Send[17] = 42;  matrix_b_Send[18] = 90;  matrix_b_Send[19] = 20;
		matrix_b_Send[20] = 15; matrix_b_Send[21] = 25;  matrix_b_Send[22] = 7;   matrix_b_Send[23] = 63;  matrix_b_Send[24] = 12;
	end*/

	// Criação de Matriz teste para operações
	initial begin
		integer i;
		for (i = 0; i < 25; i = i + 1) begin
			matrix_a_Send[i] = i + 1;					// Inicializa matriz_a com valores de 1 a 25	
			matrix_b_Send[i] = 1;  						// Incializa matriz_b com valores fixo de 1
		end
	end

	// Gerador de clock de 1 segundo  
    always @(posedge clk) begin
        if (counter < 25_000_000 - 1) counter <= counter + 1;
        else begin
            counter <= 0;
            clk_1_segundo <= ~clk_1_segundo;
        end
    end
 
    // Bloco sempre ativado por borda de clock ou reset
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			state <= S0_INIT_WRITE;
			mem_addr <= 0;
			mem_we <= 0;
			index <= 0;
			Counter_wait <= 0;
			start_deter <= 0;
			matrix_a_Receive <= 0;
			matrix_b_Receive <= 0;
		end else begin
			case (state)
				// Estado 0: Início da escrita
				S0_INIT_WRITE: begin // 000
					if (!button) begin
						mem_we <= 1;
						mem_data_in <= {matrix_b_Send[index], matrix_a_Send[index]};
						mem_addr <= index;
						index <= index + 1;
						if (index >= 25) begin
							mem_we <= 0;
							state <= S1_WAIT_WRITE;
						end
					end
				end

				// Estado 1: Pequena espera pós escrita
				S1_WAIT_WRITE: begin // 001
					if (Counter_wait < 3) Counter_wait <= Counter_wait + 1;
					else begin
						index <= 0;
						mem_addr <= 0;
						Counter_wait <= 0;
						state <= S2_READ_MEM;
					end
				end

				// Estado 2: Leitura das matrizes
				S2_READ_MEM: begin //010
					mem_we <= 0;
					matrix_a_Receive[(index*8) +: 8] <= mem_data_out[7:0];
					matrix_b_Receive[(index*8) +: 8] <= mem_data_out[15:8];
					mem_addr <= index;
					index <= index + 1;
					if (index >= 25) begin
						index <= 0;
						start_deter <= 1;
						state <= S3_WAIT_READ;
					end
				end

				// Estado 3: Processamento
				S3_WAIT_READ: begin //011
					if (Counter_wait < 70) begin 
						Counter_wait <= Counter_wait + 1;
					end 
					else begin
						start_deter <= 0;
						state <= S4_PROCESS;
					end
				end

				// Estado 4: Processamento
				S4_PROCESS: begin // 100
					if (index < 25)  begin
						matrix_Result[index] <= $signed(matrix_out[index*8 +: 8]);
						index <= index + 1;
					end
					else begin
						index <= 0;
						mem_addr <= 25;
						Counter_wait <= 0;
						mem_we <= 1;
						state <= S5_WAIT_PROCESS;
					end
				end

				// Estado 5: Espera pelo processamento
				S5_WAIT_PROCESS: begin //101
					if (Counter_wait < 3) begin 
						Counter_wait <= Counter_wait + 1;
					end 
					else begin
						Counter_wait <= 0;
						state <= S6_WRITE_RESULT;
					end
				end

				// Estado 6: Escrita dos resultados
				S6_WRITE_RESULT: begin // 110
					mem_data_in <= {8'b0, matrix_Result[index]};
					mem_addr <= 25 + index; // Escreve de 25 a 49
					index <= index + 1;
					if (index >= 25) begin
						mem_we <= 0;
						state <= S7_DONE;
					end 
				end

				// Estado 7: Finalizado, reinicia
				S7_DONE: begin // 111
					state <= S0_INIT_WRITE;
					index <= 0;
					mem_addr <= 0;
				end

				default: state <= S0_INIT_WRITE;
			endcase
		end
	end


	// Atribui o valor dos LEDs conforme o estado atual
	assign rst = !reset;
	assign LEDsContador = index_display;

	reg test_antigo;
	reg signed [7:0] signed_value;
	reg [7:0] abs_value;

	// Area de Debug do codigo
	always @(posedge clk_1_segundo) begin
		test_antigo <= test; // armazena o valor anterior do botão

		if (!test && test_antigo) begin
			// detectou a borda de subida: botão foi pressionado

			// Pega o valor da matriz
			signed_value = matrix_out[(index_display*8) +: 8];
			abs_value = (signed_value < 0) ? -signed_value : signed_value;

			// Primeiro dígito (unidade)
			Display0 <= seg7(abs_value % 10);
			Display1 <= seg7((abs_value / 10) % 10);

			// Avança para o próximo valor da matriz
			if (index_display < 24)
				 index_display <= index_display + 1;
			else
				 index_display <= 0; // reinicia
		end
	end
	
	function [6:0] seg7;
		input [3:0] val;
		begin
			case (val)
				4'd0: seg7 = 7'b1000000;
				4'd1: seg7 = 7'b1111001;
				4'd2: seg7 = 7'b0100100;
				4'd3: seg7 = 7'b0110000;
				4'd4: seg7 = 7'b0011001;
				4'd5: seg7 = 7'b0010010;
				4'd6: seg7 = 7'b0000010;
				4'd7: seg7 = 7'b1111000;
				4'd8: seg7 = 7'b0000000;
				4'd9: seg7 = 7'b0010000;
				default: seg7 = 7'b1111111;
			endcase
		end
	endfunction

endmodule
