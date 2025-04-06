module determinante_2x2 (
    input signed [31:0] matriz_2x2,  // Entrada da matriz 2x2 compactada em 32 bits
    output reg signed [7:0] det,     // Saída do determinante (8 bits com sinal)
    output reg overflow_flag         // Flag de overflow
);

    // Extração dos elementos da matriz (cada um com 8 bits com sinal)
    wire signed [7:0] a = matriz_2x2[31:24];  // Elemento a11
    wire signed [7:0] b = matriz_2x2[23:16];  // Elemento a12
    wire signed [7:0] c = matriz_2x2[15:8];   // Elemento a21
    wire signed [7:0] d = matriz_2x2[7:0];    // Elemento a22

    // Cálculo do determinante em 16 bits para evitar overflow intermediário
    wire signed [15:0] det_temp = (a * d) - (b * c);

    always @(*) begin
        // Atribuição do resultado com truncamento para 8 bits
        det = det_temp[7:0];  // Pega apenas os 8 bits menos significativos
        
        // Detecção de overflow (verifica se o resultado excede 8 bits com sinal)
        overflow_flag = (det_temp > 127) || (det_temp < -128);
    end

endmodule