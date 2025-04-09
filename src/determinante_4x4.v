module determinante_4x4(
    input clk,
    input [127:0] A,
    output reg signed [7:0] det,
    output reg overflow_flag
);

    wire signed [7:0] a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p;
    reg signed [15:0] M1, M2, M3, M4;
    reg signed [15:0] det_temp;

    assign a = A[127:120];
    assign b = A[119:112];
    assign c = A[111:104];
    assign d = A[103:96];
    assign e = A[95:88];
    assign f = A[87:80];
    assign g = A[79:72];
    assign h = A[71:64];
    assign i = A[63:56];
    assign j = A[55:48];
    assign k = A[47:40];
    assign l = A[39:32];
    assign m = A[31:24];
    assign n = A[23:16];
    assign o = A[15:8];
    assign p = A[7:0];

    // Função de multiplicação bit a bit
    function signed [15:0] bit_mult;
        input signed [7:0] a, b;
        begin
            bit_mult = 0;
            if (b[0]) bit_mult = bit_mult + a;
            if (b[1]) bit_mult = bit_mult + (a <<< 1);
            if (b[2]) bit_mult = bit_mult + (a <<< 2);
            if (b[3]) bit_mult = bit_mult + (a <<< 3);
            if (b[4]) bit_mult = bit_mult + (a <<< 4);
            if (b[5]) bit_mult = bit_mult + (a <<< 5);
            if (b[6]) bit_mult = bit_mult + (a <<< 6);
            if (b[7]) bit_mult = bit_mult - (a <<< 7);  // complemento de dois
        end
    endfunction

    // Bloco combinacional
    always @(posedge clk) begin
        M1 = bit_mult(f, (bit_mult(k, p) - bit_mult(l, o)))
           - bit_mult(g, (bit_mult(j, p) - bit_mult(l, m)))
           + bit_mult(h, (bit_mult(j, o) - bit_mult(k, m)));

        M2 = bit_mult(e, (bit_mult(k, p) - bit_mult(l, o)))
           - bit_mult(g, (bit_mult(i, p) - bit_mult(l, m)))
           + bit_mult(h, (bit_mult(i, o) - bit_mult(k, m)));

        M3 = bit_mult(e, (bit_mult(j, p) - bit_mult(l, n)))
           - bit_mult(f, (bit_mult(i, p) - bit_mult(l, m)))
           + bit_mult(h, (bit_mult(i, n) - bit_mult(j, m)));

        M4 = bit_mult(e, (bit_mult(j, o) - bit_mult(k, n)))
           - bit_mult(f, (bit_mult(i, o) - bit_mult(k, m)))
           + bit_mult(g, (bit_mult(i, n) - bit_mult(j, m)));

        det_temp = bit_mult(a, M1) - bit_mult(b, M2) + bit_mult(c, M3) - bit_mult(d, M4);

        // Atribuição direta ao determinante (sem truncar nem limitar)
        det = det_temp[7:0];

        // Verificação de overflow
        if (det_temp > 127 || det_temp < -128)
            overflow_flag = 1;
        else
            overflow_flag = 0;
    end

endmodule