module determinante_3x3 (
    input signed [71:0] matriz_3x3,  // Matriz 3x3 compactada (9 elementos de 8 bits)
    output reg signed [7:0] det,     // Resultado do determinante (8 bits com sinal)
    output reg overflow_flag         // Flag de overflow
);

    // Extraindo os elementos da matriz 3x3
    wire signed [7:0] a = matriz_3x3[71:64];
    wire signed [7:0] b = matriz_3x3[63:56];
    wire signed [7:0] c = matriz_3x3[55:48];
    wire signed [7:0] d = matriz_3x3[47:40];
    wire signed [7:0] e = matriz_3x3[39:32];
    wire signed [7:0] f = matriz_3x3[31:24];
    wire signed [7:0] g = matriz_3x3[23:16];
    wire signed [7:0] h = matriz_3x3[15:8];
    wire signed [7:0] i = matriz_3x3[7:0];

    // Cálculos intermediários com extensão para 32 bits
    wire signed [31:0] a_ext = a;
    wire signed [31:0] b_ext = b;
    wire signed [31:0] c_ext = c;
    wire signed [31:0] d_ext = d;
    wire signed [31:0] e_ext = e;
    wire signed [31:0] f_ext = f;
    wire signed [31:0] g_ext = g;
    wire signed [31:0] h_ext = h;
    wire signed [31:0] i_ext = i;

    // Cálculo dos produtos
    wire signed [31:0] ei = e_ext * i_ext;
    wire signed [31:0] fh = f_ext * h_ext;
    wire signed [31:0] di = d_ext * i_ext;
    wire signed [31:0] fg = f_ext * g_ext;
    wire signed [31:0] dh = d_ext * h_ext;
    wire signed [31:0] eg = e_ext * g_ext;

    // Cálculo dos menores
    wire signed [31:0] minor1 = ei - fh;
    wire signed [31:0] minor2 = di - fg;
    wire signed [31:0] minor3 = dh - eg;

    // Cálculo final do determinante
    wire signed [31:0] term1 = a_ext * minor1;
    wire signed [31:0] term2 = b_ext * minor2;
    wire signed [31:0] term3 = c_ext * minor3;
    wire signed [31:0] det_temp = term1 - term2 + term3;

    always @(*) begin
        // Atribui o resultado truncado para 8 bits
        det = det_temp[7:0];
        
        // Verifica se houve overflow (resultado não cabe em 8 bits com sinal)
        overflow_flag = (det_temp > 127) || (det_temp < -128);
    end

endmodule