// Módulo de multiplicação de matrizes com suporte a diferentes tamanhos (2x2, 3x3, 4x4, 5x5)
module multiplicacao (
    input signed [199:0] A,   
    input signed [199:0] B,   
    input [1:0] matrix_size,  // 00: 2x2, 01: 3x3, 10: 4x4, 11: 5x5
    output reg [199:0] C,         
    output reg overflow_flag      // Sinal de estouro (overflow) se algum valor exceder o intervalo [-128,127]
);

    integer size, i, j, k;
    reg signed [7:0] a_elem, b_elem;
    reg signed [15:0] temp_sum;
    reg [4:0] index;
    reg overflow_local;

    always @(*) begin
        case (matrix_size)
            2'b00: size = 2;
            2'b01: size = 3;
            2'b10: size = 4;
            default: size = 5;
        endcase

        C = 0;
        overflow_local = 0;

        for (i = 0; i < size; i = i + 1) begin
            for (j = 0; j < size; j = j + 1) begin
                temp_sum = 0;
                for (k = 0; k < size; k = k + 1) begin
                    a_elem = A[(i*40) + (k*8) +: 8];
                    b_elem = B[(k*40) + (j*8) +: 8];
                    temp_sum = temp_sum + bit_mult(a_elem, b_elem);
                end
                index = i*5 + j;
                C[(index*8) +: 8] = temp_sum[7:0];
                if (temp_sum > 127 || temp_sum < -128)
                    overflow_local = 1;
            end
        end

        overflow_flag = overflow_local;
    end

    // Função auxiliar para multiplicação bit a bit
    function signed [15:0] bit_mult;
        input signed [7:0] a, b;
        begin
            bit_mult = 0;
            if (b[0]) bit_mult = bit_mult + a;
            if (b[1]) bit_mult = bit_mult + (a << 1);
            if (b[2]) bit_mult = bit_mult + (a << 2);
            if (b[3]) bit_mult = bit_mult + (a << 3);
            if (b[4]) bit_mult = bit_mult + (a << 4);
            if (b[5]) bit_mult = bit_mult + (a << 5);
            if (b[6]) bit_mult = bit_mult + (a << 6);
            if (b[7]) bit_mult = bit_mult - (a << 7); // Ajuste para complemento de dois
        end
    endfunction

endmodule