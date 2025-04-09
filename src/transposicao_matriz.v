module transposicao_matriz( 
    input signed [199:0] matrix_A,             // Matriz original (até 5x5 de 8 bits)
    input [1:0] matrix_size,                   // Tamanho da matriz (2x2, 3x3, 4x4, 5x5)
    output reg signed [199:0] m_transposta_A   // Matriz transposta (resultado)
);

    wire [2:0] size;  // Tamanho real da matriz (2 a 5)
    assign size = (matrix_size == 2'b00) ? 2 :
                  (matrix_size == 2'b01) ? 3 :
                  (matrix_size == 2'b10) ? 4 : 5;

    integer i, j;

    always @(*) begin
        m_transposta_A = 200'd0;

        for (i = 0; i < 25; i = i + 1) begin
            j = (i / 5) + (i % 5) * 5;  // Índice transposto

            if ((i % 5) < size && (i / 5) < size) begin
                m_transposta_A[j * 8 +: 8] = matrix_A[i * 8 +: 8];
            end else begin
                m_transposta_A[j * 8 +: 8] = 8'sd0;
            end
        end
    end

endmodule
