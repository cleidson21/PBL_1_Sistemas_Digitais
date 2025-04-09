module oposicao_matriz (
    input signed [199:0] matrix_A,
    input [1:0] matrix_size,
    output reg signed [199:0] m_oposta_A
);

    wire [4:0] active_elements;

    assign active_elements = (matrix_size == 2'b00) ? 4 :
                             (matrix_size == 2'b01) ? 9 :
                             (matrix_size == 2'b10) ? 16 :
                             25;

    integer i;
    always @(*) begin
        for (i = 0; i < 25; i = i + 1) begin
            if (i < active_elements) begin
                // Extração do valor com sinal e atribuição com negação
                m_oposta_A[i*8 +: 8] = -$signed(matrix_A[i*8 +: 8]);
            end else begin
                m_oposta_A[i*8 +: 8] = 8'sd0;
            end
        end
    end

endmodule