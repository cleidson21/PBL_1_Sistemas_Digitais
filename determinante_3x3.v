module determinante_3x3 (
    input signed [71:0] matriz_3x3,  // Matriz 3x3 compactada (9 elementos de 8 bits)
    output reg signed [31:0] det     // Resultado do determinante
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

    always @(*) begin
        // Calculando o determinante: 
        // det = a(ei - fh) - b(di - fg) + c(dh - eg)
        det = (a * (e * i - f * h)) - (b * (d * i - f * g)) + (c * (d * h - e * g));
    end

endmodule
