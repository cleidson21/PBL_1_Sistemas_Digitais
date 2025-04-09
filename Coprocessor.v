module Coprocessor (
	input wire clk,	          		// Sinal de clock de entrada
	input wire reset,	          		// Sinal de reset para reiniciar a operação
	input wire button,	      		// Botão para controlar a execução do módulo
	input wire [2:0] op_code,	    	// Código de operação (para determinar a operação a ser executada)
); 	
	
	// Declaração das variáveis de controle
	reg mem_we = 1;								// Controle de escrita na memória 
	reg start_deter = 0;							// Controle do sinal de início do cálculo
	reg [1:0] matrix_size;						// Pode ser 2x2 (2'b00), 3x3 (2'b01), 4x4 (2'b10) ou 5x5 (2'b11)
	reg [6:0] mem_addr = 0;						// Endereço de memória
	reg [15:0] mem_data_in;						// Dados a serem escritos na memória (16 bits)
	reg [2:0] state = 0;							// Estado do sistema (3 bits)
	reg [6:0] Counter_wait = 0;				// Contador para delays
	reg [4:0] index = 0;							// Índice para acesso
	reg [7:0] scalar = 8'd3;					// Escalar para multiplicação
	wire [15:0] mem_data_out; 					// Dados lidos da memória
	wire rst;

	// Matrizes e registradores
	reg signed [7:0] matrix_a_Send [0:24];
	reg signed [7:0] matrix_b_Send [0:24];
	reg [199:0] matrix_a_Receive;
	reg [199:0] matrix_b_Receive;
	reg signed [7:0] matrix_Result [0:25];
	wire [199:0] matrix_out;

	// Estados FSM
	localparam S0_INIT_WRITE   = 3'b000;
	localparam S1_WAIT_WRITE   = 3'b001;
	localparam S2_READ_MEM     = 3'b010;
	localparam S3_WAIT_READ    = 3'b011;
	localparam S4_PROCESS      = 3'b100;
	localparam S5_WAIT_PROCESS = 3'b101;
	localparam S6_WRITE_RESULT = 3'b110;
	localparam S7_DONE         = 3'b111;
	
	// Parametros da FSM
	localparam PROCESS_DELAY = 5;
	localparam RESULT_START_ADDR = 25;

	// Instancia ALU
	Alu uut (
		.op_code(op_code),
		.matrix_a(matrix_a_Receive),
		.matrix_b(matrix_b_Receive),
		.matrix_size(matrix_size),
		.scalar(scalar),
		.overflow(overflow),
		.result_final(matrix_out),
		.clk(clk),
		.rst(rst),
		.start(start_deter)
	);

	// Instancia Memória
	MemoryBlock memory (
		.address(mem_addr),
		.clock(clk),
		.data(mem_data_in),
		.wren(mem_we),
		.q(mem_data_out)
	);

	initial begin
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
		
		matrix_size = 2'b11;
	end
	
	// Variaveis para redutor de clock
	reg clk_Reduced;
	reg [25:0] counter = 0;
	
	// Gerador de clock de 1 segundo para sincronia
   always @(posedge clk) begin
       if (counter < 4_000_000 - 1) counter <= counter + 1;
       else begin
           counter <= 0;
           clk_Reduced <= ~clk_Reduced;
       end
   end

	// FSM principal
	always @(posedge clk_Reduced or posedge rst) begin
		if (rst) begin
			mem_addr <= 0;
			mem_we <= 0;
			mem_data_in <= 0;
			index <= 0;
			Counter_wait <= 0;
			start_deter <= 0;
			matrix_a_Receive <= 0;
			matrix_b_Receive <= 0;
			state <= S0_INIT_WRITE;
		end else begin
			case (state)
				S0_INIT_WRITE: begin
					if (!button) begin
						mem_we <= 1;
						mem_data_in <= {matrix_b_Send[index], matrix_a_Send[index]};
						state <= S1_WAIT_WRITE;	
					end
				end

				S1_WAIT_WRITE: begin
					if (index < 24) begin
						mem_addr <= mem_addr + 1;
						index <= index + 1;
						state <= S0_INIT_WRITE;
					end else begin
						mem_addr <= 0;
						index <= 0;					
						mem_we <= 0;
						Counter_wait <= 0;
						state <= S2_READ_MEM;
					end
				end

				S2_READ_MEM: begin
					matrix_a_Receive[(index*8) +: 8] <= mem_data_out[7:0];
					matrix_b_Receive[(index*8) +: 8] <= mem_data_out[15:8];
					state <= S3_WAIT_READ;
				end

				// Estado 3: Incrementa índice e verifica se terminou
				S3_WAIT_READ: begin // 011
					if (index < 24) begin
						mem_addr <= mem_addr + 1;
						index <= index + 1;
						state <= S2_READ_MEM;  // Volta a ler o próximo valor
					end 
					else begin
						index <= 0;
						start_deter <= 1;
						state <= S4_PROCESS;
					end
				end

				S4_PROCESS: begin
					start_deter <= 0;
					if (Counter_wait < PROCESS_DELAY) begin
						Counter_wait <= Counter_wait + 1;
					end 
					else begin
						matrix_Result[index] <= matrix_out[(index*8) +: 8];
						if (index < 24) begin 
							index <= index + 1;
						end
						else begin
							index <= 0;
							Counter_wait <= 0;
							mem_we <= 1;
							mem_addr <= RESULT_START_ADDR;
							state <= S5_WAIT_PROCESS;
						end
					end
				end

				S5_WAIT_PROCESS: begin
					mem_data_in <= {8'b0, matrix_Result[index]};
					state <= S6_WRITE_RESULT;
				end

				S6_WRITE_RESULT: begin
					if (index < 24) begin
						mem_addr <= mem_addr + 1;
						index <= index + 1;
						state <= S5_WAIT_PROCESS;
					end else begin
						mem_addr <= mem_addr + 1;
						mem_data_in <= {8'b0, overflow};
						state <= S7_DONE;
					end 
				end

				S7_DONE: begin
					mem_we <= 0;
					if (button) begin
						state <= S0_INIT_WRITE;
						index <= 0;
						mem_addr <= 0;
					end
				end

				default: state <= S0_INIT_WRITE;
			endcase
		end
	end

	assign rst = !reset;
endmodule
