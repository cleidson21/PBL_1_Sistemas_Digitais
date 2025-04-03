module transposicao_matriz(
    input signed [199:0] matrix_A,             // Matriz original (5x5 de 8 bits)
    output reg signed [199:0] m_transposta_A   // Matriz transposta (resultado)
);

    integer i, j;  // Variáveis para percorrer as linhas e colunas da matriz

    always @(*) begin
        // Realiza a transposição da matriz de 5x5
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                // Transpõe a matriz movendo os elementos de matrix_A para m_transposta_A
                m_transposta_A[((j << 2) + j + i) << 3 +: 8] = 
                    matrix_A[((i << 2) + i + j) << 3 +: 8]; // A transposição é feita usando deslocamento de bits
            end
        end
    end
    
endmodule
