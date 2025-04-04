module MainCoprocessor (
    input wire clk,          // Sinal de clock de entrada
    input wire reset,          // Sinal de reset para reiniciar a operação
    input wire button,       // Botão para controlar a execução do módulo
        // Código de operação (para determinar a operação a ser executada)
    output wire overflow,    // Indicador de overflow
    output [1:0] LEDs        // LEDs para representar o estado do processo
);

	wire [2:0] op_code;
	 
	assign op_code = 001 ; 
	
    // Declaração das variáveis de controle
    reg [6:0] mem_addr;      						// Endereço de memória (7 bits)
    reg mem_we, start_deter; 						// Controle de escrita na memória e sinal de início do cálculo
    reg [15:0] mem_data_in;  						// Dados a serem escritos na memória (16 bits)
    reg [1:0] state;         						// Estado do sistema (2 bits)
    reg [6:0] Counter_wait;  						// Contador para temporização e delays (7 bits)
    reg [4:0] index;         						// Índice para acessar elementos das matrizes
    reg [4:0] shift_index;   						// Índice para controle do shift das matrizes
    reg [7:0] scalar;        						// Escalar para multiplicação das matrizes
    wire [15:0] mem_data_out; 					// Dados lidos da memória (16 bits)
	 wire rst;

    // Matrizes de teste e resultados
    reg signed [7:0] matrix_a_Send [0:24];   // Matriz A de entrada (valores de 8 bits com sinal)
    reg signed [7:0] matrix_b_Send [0:24];   // Matriz B de entrada (valores de 8 bits com sinal)
    reg signed [199:0] matrix_a_Receive;     // Matriz A para processamento (199 bits)
    reg signed [199:0] matrix_b_Receive;     // Matriz B para processamento (199 bits)
    reg signed [7:0] matrix_Result [0:24];   // Resultado da multiplicação das matrizes
    wire signed [199:0] matrix_out;          // Resultado final do coprocessador

    // Instancia o coprocessador que executa as operações de matrizes
    Coprocessor uut (
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

	    mem_we = 1;  									// Ativa a escrita na memória
	    mem_addr = 0; 								// Inicia o endereço da memória
	    scalar = 8'd3; 								// Define o valor do escalar (3)
    end*/
	 
	 	// Criação de Matriz teste para operações
    initial begin
        integer i;
        for (i = 0; i < 25; i = i + 1) begin
            matrix_a_Send[i] = i + 1;					// Inicializa matriz_a com valores de 1 a 25	
            matrix_b_Send[i] = 1;  						// Incializa matriz_b com valores fixo de 1
        end
        mem_addr = 0;
		  //valor colocado 
		  state <= 0 ; 
    end
	 
    // Bloco sempre ativado por borda de clock ou reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Caso de reset: retorna para o estado inicial
            state <= 2'b00;
            mem_addr <= 0;
            index <= 0;
            shift_index <= 0;
            Counter_wait <= 0;
            matrix_a_Receive <= 0;
            matrix_b_Receive <= 0;

        end else begin
            case (state)
                // Estado 0: Escreve as matrizes na memória
                2'b00: begin
                    if (!button) begin
                        mem_we <= 1;  			// Ativa a escrita na memória
                        if (index < 25) begin
                            // Preenche a memória com os valores de A e B
                            mem_data_in <= {matrix_b_Send[index], matrix_a_Send[index]};
                            mem_addr <= mem_addr + 1;
                            index <= index + 1;
                        end else begin
                            // Após escrever as 25 posições, muda para o estado de leitura
                            mem_we <= 0;
                            mem_addr <= 0;
                            index <= 0;
                            state <= 2'b01;
                        end
                    end
                end
                
                // Estado 1: Lê os dados das matrizes da memória
                2'b01: begin
                    mem_we <= 0; // Desativa a escrita na memória
                    if (Counter_wait < 1) begin
                        Counter_wait <= Counter_wait + 1; // Aguarda por 3 ciclos de clock
                    end else if (index < 25) begin
                        // Lê os dados das matrizes A e B
                        matrix_a_Receive[(index << 3) +: 8] <= mem_data_out[7:0];
                        matrix_b_Receive[(index << 3) +: 8] <= mem_data_out[15:8];
                        mem_addr <= mem_addr + 1;        // Avança o endereço da memória
                        index <= index + 1;
                    end else begin
                        // Após ler todos os dados, prepara para o cálculo
                        index <= 0;
                        Counter_wait <= 0;
                        state <= 2'b10;  // Muda para o estado de cálculo
                        start_deter <= 1; // Inicia o cálculo do determinante
                    end
                end 
                
                // Estado 2: Realiza o cálculo (determinante ou operações)
                2'b10: begin 
                    if (Counter_wait < 70) begin
                        // Espera mais tempo devido à operação sequencial
                        Counter_wait <= Counter_wait + 1;
                    end else begin
                        // Armazena os resultados calculados
                        for (index = 0; index < 25; index = index + 1) begin
                            matrix_Result[index] <= matrix_out[index << 3 +: 8]; // Extrai resultados da saída do coprocessador
                        end
                        index <= 0;
                        shift_index <= 0;
                        start_deter <= 0;  // Finaliza o cálculo
                        Counter_wait <= 0;
                        state <= 2'b11; // Avança para o estado de escrita dos resultados
                    end
                end
                
                // Estado 3: Escreve o resultado na memória
                2'b11: begin
                    mem_we <= 1;  // Ativa a escrita na memória
                    if (Counter_wait < 3) begin
                        Counter_wait <= Counter_wait + 1; // Aguarda 3 ciclos de clock
                    end else if (index < 25) begin
                        // Escreve os resultados calculados na memória
								mem_addr <= mem_addr + 1;
                        mem_data_in <= {8'b0, matrix_Result[index]};
                        index <= index + 1;
                    end else begin
                        // Finaliza a escrita e retorna ao estado inicial
                        mem_we <= 0;
                        mem_addr <= 0;
                        index <= 0;
                        state <= 2'b00;
                    end
                end
                
                // Estado padrão: retorna ao estado inicial
                default: begin
                    mem_we <= 0;
                    mem_addr <= 0;
                    index <= 0;
                    state <= 2'b00;
                end
            endcase
        end
    end

    // Atribui o valor dos LEDs conforme o estado atual
    assign LEDs = state ;
	 assign rst = !reset;

endmodule
