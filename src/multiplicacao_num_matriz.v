module multiplicacao_num_matriz (
    input signed [199:0] matriz_A,           // Matriz A de entrada (25 elementos de 8 bits)
    input signed [7:0] num_inteiro,          // Número escalar (8 bits)
    input [1:0] matrix_size,                 // Tamanho da matriz (2x2, 3x3, 4x4, 5x5)
    output reg signed [199:0] nova_matriz_A, // Matriz resultante da multiplicação
    output reg overflow_flag                 // Sinal geral de overflow
);

    wire [4:0] active_elements;              // Quantidade de elementos ativos
    assign active_elements = (matrix_size == 2'b00) ? 4 :
                             (matrix_size == 2'b01) ? 9 :
                             (matrix_size == 2'b10) ? 16 :
                             25;

    wire signed [15:0] resultado [0:24];     // Resultado intermediário da multiplicação
    wire overflow [0:24];                    // Sinal de overflow por elemento

    genvar i;
    generate
        for (i = 0; i < 25; i = i + 1) begin : multiplicacao
            wire signed [7:0] elemento_matriz = matriz_A[i*8 +: 8];
            assign resultado[i] = bit_mult(elemento_matriz, num_inteiro);

            // Overflow se bits mais significativos forem diferentes da extensão de sinal
            assign overflow[i] = (resultado[i][15:8] != {8{resultado[i][7]}}) ? 1'b1 : 1'b0;
        end
    endgenerate

    integer j;
    always @(*) begin
        nova_matriz_A = 0;
        overflow_flag = 0;

        for (j = 0; j < 25; j = j + 1) begin
            if (j < active_elements) begin
                nova_matriz_A[j*8 +: 8] = resultado[j][7:0];
                if (overflow[j]) overflow_flag = 1;
            end else begin
                nova_matriz_A[j*8 +: 8] = 8'd0;
            end
        end
    end

    // Função de multiplicação por deslocamento (shift-and-add)
    function signed [15:0] bit_mult;
        input signed [7:0] a, b;
        integer k;
        reg signed [15:0] acc;
        begin
            acc = 0;
            for (k = 0; k < 7; k = k + 1)
                if (b[k]) acc = acc + (a <<< k);
            if (b[7]) acc = acc - (a <<< 7);  // Ajuste para bit de sinal
            bit_mult = acc;
        end
    endfunction

endmodule