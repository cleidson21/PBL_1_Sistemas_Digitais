module determinante_2x2 (
    input signed [31:0] matriz_2x2,  // Matriz 2x2 compactada
    output reg signed [31:0] det     // Resultado do determinante
);

    // Extraindo os elementos da matriz 2x2
    wire signed [31:0] a = matriz_2x2[31:24];
    wire signed [31:0] b = matriz_2x2[23:16];
    wire signed [31:0] c = matriz_2x2[15:8];
    wire signed [31:0] d = matriz_2x2[7:0];

    always @(*) begin
        // Calculando o determinante: det = a * d - b * c
        det = (a * d) - (b * c);
    end

endmodule
