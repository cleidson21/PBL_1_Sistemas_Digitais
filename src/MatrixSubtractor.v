module MatrixSubtractor ( 
    input signed [199:0] matrix_A,      		// Matriz A de entrada (25 elementos de 8 bits)
    input signed [199:0] matrix_B,      		// Matriz B de entrada (25 elementos de 8 bits)
    input [1:0] matrix_size,            		// Tamanho da matriz (2x2, 3x3, 4x4, 5x5)
    output reg signed [199:0] result_out, 		// Resultado da subtração de A e B
    output reg overflow                 		// Flag de overflow 
);

    // Corrigido: declaração do número de elementos ativos com base no tamanho
    wire [4:0] active_elements;

    assign active_elements = (matrix_size == 2'b00) ? 4 :
                             (matrix_size == 2'b01) ? 9 :
                             (matrix_size == 2'b10) ? 16 :
                             25;

    // Sinais internos para armazenar a diferença e verificar overflow
    wire signed [8:0] diff [0:24];            			// 9 bits para detectar overflow
    wire overflow_check [0:24];        					// Verificação de overflow para cada subtração

    // Geração para calcular a diferença e verificar overflow
    genvar i;
    generate
        for (i = 0; i < 25; i = i + 1) begin : diff_and_check
            assign diff[i] = matrix_A[i*8 +: 8] - matrix_B[i*8 +: 8];  // Subtração

            // Detecta overflow em subtração: sinais diferentes e resultado fora do intervalo
            assign overflow_check[i] = (matrix_A[i*8+7] != matrix_B[i*8+7]) &&
                                       (diff[i][8] != matrix_A[i*8+7]);
        end
    endgenerate

    // Bloco sempre sensível a qualquer alteração
    integer j;
    always @(*) begin
        overflow = 0;           // Inicializa overflow
        result_out = 0;         // Inicializa resultado

        for (j = 0; j < 25; j = j + 1) begin
            if (j < active_elements) begin
                result_out[j*8 +: 8] = diff[j][7:0];     // Armazena resultado da subtração
                if (overflow_check[j]) overflow = 1;     // Atualiza overflow se detectado
            end else begin
                result_out[j*8 +: 8] = 8'd0;             // Zera posições não utilizadas
            end
        end
    end

endmodule