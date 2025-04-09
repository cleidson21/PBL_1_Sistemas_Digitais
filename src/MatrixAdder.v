module MatrixAdder (
    input signed [199:0] matrix_A,      			// Matrizes de 200 bits (25 elementos de 8 bits cada)
    input signed [199:0] matrix_B,      			// Matrizes de 200 bits (25 elementos de 8 bits cada)
    input [1:0] matrix_size,            			// Tamanho da matriz (2x2, 3x3, 4x4, 5x5)
    output reg signed [199:0] result_out, 		// Resultado da soma das matrizes
    output reg overflow                 			// Flag de overflow
);

    wire signed [8:0] sum [0:24];               // Soma de 25 elementos (9 bits para considerar overflow)
    wire overflow_check [0:24];                 // Flag de overflow para cada soma
    wire [4:0] active_elements;                 // Número de elementos ativos da matriz, baseado no tamanho

    // Determina o número de elementos ativos com base no tamanho da matriz
    assign active_elements = (matrix_size == 2'b00) ? 4 :
                             (matrix_size == 2'b01) ? 9 :
                             (matrix_size == 2'b10) ? 16 :
                             25;

    // Geração para calcular a soma de cada elemento e verificar overflow
    genvar i;
    generate
        for (i = 0; i < 25; i = i + 1) begin : adder_loop
            wire signed [7:0] a_elem = matrix_A[i*8 +: 8];
            wire signed [7:0] b_elem = matrix_B[i*8 +: 8];

            assign sum[i] = a_elem + b_elem;

           assign overflow_check[i] = (a_elem[7] == b_elem[7]) && (sum[i][7] != a_elem[7]);
        end
    endgenerate

    // Bloco sempre sensível a qualquer alteração
    integer j;
    always @(*) begin
        overflow = 0;
        result_out = 0;

        for (j = 0; j < 25; j = j + 1) begin
            if (j < active_elements) begin
                result_out[j*8 +: 8] = sum[j][7:0];
                if (overflow_check[j]) overflow = 1;
            end else begin
                result_out[j*8 +: 8] = 8'd0;
            end
        end
    end
endmodule