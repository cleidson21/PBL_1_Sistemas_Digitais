module MatrixSubtractor (
    input signed [199:0] matrix_A,  // Matriz A de entrada (25 elementos de 8 bits)
    input signed [199:0] matrix_B,  // Matriz B de entrada (25 elementos de 8 bits)
    output reg signed [199:0] result_out,  // Resultado da subtração de A e B
    output reg overflow             // Flag de overflow (indica se ocorreu overflow)
);

    // Declaração de sinais internos
    wire [8:0] diff [0:24];          // Vetor para armazenar a diferença de A[i] e B[i] (com 9 bits para overflow)
    wire overflow_check [0:24];      // Vetor para checar se ocorreu overflow em cada subtração

    genvar i;
    generate
        for (i = 0; i < 25; i = i + 1) begin : diff_and_check
            // Realiza a subtração e verifica overflow
            assign diff[i] = matrix_A[(i << 3) +: 8] - matrix_B[(i << 3) +: 8];  // Subtração
            // Detecção de overflow: verifique se os bits mais significativos de A e B são diferentes
            // e se o bit de borrow da subtração indica overflow.
            assign overflow_check[i] = (matrix_A[(i << 3) + 7] != matrix_B[(i << 3) + 7]) && 
                                       (diff[i][8] != matrix_A[(i << 3) + 7]);
        end
    endgenerate

    // Bloco sempre para calcular o resultado e verificar overflow
    integer j;
    always @(*) begin
        overflow = 0;  // Inicializa a flag de overflow

        // Loop para gerar o resultado da subtração e verificar overflow
        for (j = 0; j < 25; j = j + 1) begin
            // Atribui o resultado da subtração (apenas os 8 bits menos significativos)
            result_out[(j << 3) +: 8] = diff[j][7:0];  
            // Atualiza a flag de overflow se algum overflow for detectado
            if (overflow_check[j]) overflow = 1;
        end
    end

endmodule
