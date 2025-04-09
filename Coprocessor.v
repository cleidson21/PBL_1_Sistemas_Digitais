module Coprocessor (
    input wire clk,               					// Sinal de clock de entrada (sincroniza o módulo)
    input wire reset,            		 			// Sinal de reset para reiniciar a operação do coprocessador
    input wire button,            					// Botão de controle para iniciar ou reiniciar o processo
    input wire [2:0] op_code,     					// Código da operação para determinar o tipo de operação a ser realizada
    input wire [1:0] matrix_size 		 			// Tamanho da matriz (2x2, 3x3, 4x4 ou 5x5)
); 

    // Variáveis de controle internas
    reg mem_we = 1;               					// Controle de escrita na memória (inicia como 1, permitindo escrita)
    reg start_deter = 0;          					// Controle para iniciar o cálculo (inicia como 0)
    reg [6:0] mem_addr = 0;       					// Endereço de memória atual
    reg [15:0] mem_data_in;       					// Dados a serem escritos na memória
    reg [2:0] state = 0;          					// Estado da máquina de estados finitos (FSM), inicializado como 0
    reg [6:0] Counter_wait = 0;   					// Contador para delays temporais (controle de tempo entre estados)
    reg [4:0] index = 0;          					// Índice para percorrer as matrizes durante a leitura e escrita
    reg [7:0] scalar = 8'd3;      					// Escalar utilizado nas operações de multiplicação
    wire [15:0] mem_data_out;     					// Dados lidos da memória durante as operações
    wire rst;                     					// Sinal de reset invertido (usado no FSM e na ALU)

    // Matrizes de entrada e saída
    reg signed [7:0] matrix_a_Send [0:24];  		// Matriz A a ser enviada para processamento
    reg signed [7:0] matrix_b_Send [0:24];  		// Matriz B a ser enviada para processamento
    reg [199:0] matrix_a_Receive;           		// Matriz A lida da memória
    reg [199:0] matrix_b_Receive;           		// Matriz B lida da memória
    reg signed [7:0] matrix_Result [0:25];  		// Matriz resultado do cálculo
    wire [199:0] matrix_out;                		// Resultado final da operação gerado pela ALU

    // Definição dos estados da FSM
    localparam S0_INIT_WRITE   = 3'b000;  		// Estado inicial para escrever matrizes na memória
    localparam S1_WAIT_WRITE   = 3'b001;  		// Espera até que a escrita nas matrizes seja concluída
    localparam S2_READ_MEM     = 3'b010;  		// Lê os dados das matrizes da memória
    localparam S3_WAIT_READ    = 3'b011;  		// Aguarda a leitura completa das matrizes
    localparam S4_PROCESS      = 3'b100;  		// Inicia o processamento da operação entre as matrizes
    localparam S5_WAIT_PROCESS = 3'b101;  		// Aguarda a finalização do processamento
    localparam S6_WRITE_RESULT = 3'b110;  		// Escreve o resultado final da operação na memória
    localparam S7_DONE         = 3'b111;  		// Estado final após a conclusão da operação

    // Parâmetros adicionais da FSM
    localparam PROCESS_DELAY = 5;         		// Delay de processamento (controla o tempo de espera durante as operações)
    localparam RESULT_START_ADDR = 25;    		// Endereço inicial onde os resultados começam a ser gravados na memória

    // Instância da Unidade Lógica e Aritmética (ALU)
    Alu uut (
        .op_code(op_code),                  		// Código da operação
        .matrix_a(matrix_a_Receive),        		// Matriz A recebida
        .matrix_b(matrix_b_Receive),        		// Matriz B recebida
        .matrix_size(matrix_size),          		// Tamanho das matrizes (2x2, 3x3, 4x4, ou 5x5)
        .scalar(scalar),                    		// Escalar para operações de multiplicação
        .overflow(overflow),                		// Indicador de overflow (não utilizado no código atual)
        .result_final(matrix_out),          		// Resultado final da operação
        .clk(clk),                          		// Sinal de clock
        .rst(rst),                          		// Sinal de reset
        .start(start_deter),                		// Sinal para iniciar o cálculo
        .process_Done(process_Done)         		// Sinal indicando que o processamento foi concluído
    );

    // Instância do bloco de memória (MemoryBlock) para armazenar os dados e resultados
    MemoryBlock memory (
        .address(mem_addr),                 // Endereço de memória
        .clock(clk),                        // Sinal de clock
        .data(mem_data_in),                 // Dados a serem escritos na memória
        .wren(mem_we),                      // Sinal de habilitação de escrita na memória
        .q(mem_data_out)                    // Dados lidos da memória
    );

    // Inicialização das matrizes de teste
    initial begin
        // Atribui valores para a matriz A
        matrix_a_Send[0]  = 10;  matrix_a_Send[1]  = 11;  matrix_a_Send[2]  = 12;  matrix_a_Send[3]  = 13;   matrix_a_Send[4]  = 14;
        matrix_a_Send[5]  = 5;   matrix_a_Send[6]  = 18;  matrix_a_Send[7]  = 39;  matrix_a_Send[8]  = 7;    matrix_a_Send[9]  = 17;
        matrix_a_Send[10] = 4;   matrix_a_Send[11] = 69;  matrix_a_Send[12] = 26;  matrix_a_Send[13] = 10;   matrix_a_Send[14] = 42;
        matrix_a_Send[15] = 3;   matrix_a_Send[16] = 9;   matrix_a_Send[17] = 16;  matrix_a_Send[18] = 24;   matrix_a_Send[19] = 32;
        matrix_a_Send[20] = 8;   matrix_a_Send[21] = 3;   matrix_a_Send[22] = 25;  matrix_a_Send[23] = 3;    matrix_a_Send[24] = 27;

        // Atribui valores para a matriz B
        matrix_b_Send[0]  = 5;   matrix_b_Send[1]  = 6;   matrix_b_Send[2]  = 7;   matrix_b_Send[3]  = 8;    matrix_b_Send[4]  = 9;
        matrix_b_Send[5]  = 76;  matrix_b_Send[6]  = 1;   matrix_b_Send[7]  = 0;   matrix_b_Send[8]  = 43;   matrix_b_Send[9]  = 18;
        matrix_b_Send[10] = 41;  matrix_b_Send[11] = 38;  matrix_b_Send[12] = 67;  matrix_b_Send[13] = 22;   matrix_b_Send[14] = 9;
        matrix_b_Send[15] = 6;   matrix_b_Send[16] = 8;   matrix_b_Send[17] = 42;  matrix_b_Send[18] = 90;   matrix_b_Send[19] = 20;
        matrix_b_Send[20] = 15;  matrix_b_Send[21] = 25;  matrix_b_Send[22] = 7;   matrix_b_Send[23] = 63;   matrix_b_Send[24] = 12;
    end

    // Gerador de clock reduzido para sincronia de 1 segundo
    reg clk_Reduced;
    reg [25:0] counter = 0;
    always @(posedge clk) begin
        if (counter < 1_000_000 - 1) 
            counter <= counter + 1;
        else begin
            counter <= 0;
            clk_Reduced <= ~clk_Reduced;  // Inverte o sinal de clock a cada 1 segundo
        end
    end

    // Máquina de Estados Finitos (FSM) que controla o fluxo do coprocessador
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
				
					 // Estado 0: Inicializa a escrita das matrizes na memória
                S0_INIT_WRITE: begin
                    if (!button) begin
                        mem_we <= 1;  						
                        mem_data_in <= {matrix_b_Send[index], matrix_a_Send[index]};  
                        state <= S1_WAIT_WRITE;  		
                    end
                end
					 
					 // Estado 1: Espera pela escrita das matrizes
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

                // Estado 2: Lê as matrizes da memória
                S2_READ_MEM: begin
                    matrix_a_Receive[(index*8) +: 8] <= mem_data_out[7:0]; 
                    matrix_b_Receive[(index*8) +: 8] <= mem_data_out[15:8];  
                    state <= S3_WAIT_READ;  
                end

                // Estado 3: Espera pela leitura das matrizes
                S3_WAIT_READ: begin
                    if (index < 24) begin
                        mem_addr <= mem_addr + 1;  
                        index <= index + 1;  
                        state <= S2_READ_MEM;  
                    end else begin
								// Finaliza a leitura e inicia o processamento
                        index <= 0;           
                        start_deter <= 1;     
                        state <= S4_PROCESS;  
                    end
                end

                // Estado 4: Processa as matrizes
                S4_PROCESS: begin
                    if (process_Done) begin
                        matrix_Result[index] <= matrix_out[(index*8) +: 8]; 
                        if (index < 24) begin
                            index <= index + 1;  
                        end else begin
                            index <= 0;          
                            Counter_wait <= 0;   
                            mem_we <= 1;         
                            mem_addr <= RESULT_START_ADDR; 
                            state <= S5_WAIT_PROCESS;  
                        end
                    end
                end

                // Estado 5: Espera pelo processamento e escreve o resultado
                S5_WAIT_PROCESS: begin
                    mem_data_in <= {8'b0, matrix_Result[index]};  
                    state <= S6_WRITE_RESULT;  
                end

                // Estado 6: Escreve o resultado na memória
                S6_WRITE_RESULT: begin
                    if (index < 24) begin
                        mem_addr <= mem_addr + 1;  	
                        index <= index + 1;        	
                        state <= S5_WAIT_PROCESS;  	
                    end else begin
                        mem_we <= 0;  	
                        state <= S7_DONE;  	
                    end
                end

                // Estado 7: Finaliza o processo e aguarda o próximo comando
                S7_DONE: begin
                    if (button) begin
                        state <= S0_INIT_WRITE;  // Volta para o estado inicial
                        index <= 0;              	
                        mem_addr <= 0;           	
                    end
                end

                // Estado por padrão: volta para o estado inicial
                default: state <= S0_INIT_WRITE;
            endcase
        end
    end

    // Sinal de reset invertido para ser utilizado na ALU
    assign rst = !reset;
endmodule
