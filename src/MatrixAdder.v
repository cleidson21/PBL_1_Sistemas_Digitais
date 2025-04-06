module MatrixAdder (
    input signed [199:0] matrix_A,  // Matriz A de entrada (25 elementos de 8 bits)
    input signed [199:0] matrix_B,  // Matriz B de entrada (25 elementos de 8 bits)
    output reg signed [199:0] result_out,  // Resultado da soma de A e B
    output reg overflow             // Flag de overflow (indica se ocorreu overflow)
);

    // Declaração de sinais internos
    wire [8:0] sum [0:24];          // Vetor para armazenar a soma de A[i] + B[i] (com 9 bits para overflow)
    wire overflow_check [0:24];     // Vetor para checar se ocorreu overflow em cada soma

    genvar i;
    generate
        for (i = 0; i < 25; i = i + 1) begin : sum_and_check
            // Realiza a soma dos elementos de A e B e verifica se ocorreu overflow
            assign sum[i] = matrix_A[(i << 3) +: 8] + matrix_B[(i << 3) +: 8];  // Soma de A e B
            // Detecção de overflow: se os bits mais significativos de A e B são iguais,
            // e o bit de carry (bit 8) da soma for diferente do bit mais significativo de A,
            // então ocorreu overflow.
            assign overflow_check[i] = (matrix_A[(i << 3) + 7] == matrix_B[(i << 3) + 7]) && 
                                       (sum[i][8] != matrix_A[(i << 3) + 7]);
        end
    endgenerate

    // Bloco sempre responsável por gerar o resultado da soma e verificar overflow
    integer j;
    always @(*) begin
        overflow = 0;  // Inicializa a flag de overflow como 0 (sem overflow)

        // Loop para calcular o resultado da soma e verificar se houve overflow
        for (j = 0; j < 25; j = j + 1) begin
            // Atribui o resultado da soma (apenas os 8 bits de menor ordem)
            result_out[(j * 8) +: 8] = sum[j][7:0];  
            // Se algum overflow for detectado, atualiza a flag de overflow para 1
            if (overflow_check[j]) overflow = 1;
        end
    end

endmodule
