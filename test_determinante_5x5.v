`timescale 1ns / 1ps
`include "determinante_4x4.v"

module tb_determinante_5x5();

    reg signed [199:0] matriz_5x5;
    wire signed [31:0] det;

    // Instancia o módulo que será testado
    determinante_5x5 uut (
        .matriz_5x5(matriz_5x5),
        .det(det)
    );

    initial begin
        // Teste 1: Matriz identidade com último elemento 2 → determinante esperado: 2
        matriz_5x5 = {
            8'sd1, 8'sd0, 8'sd0, 8'sd0, 8'sd0,
            8'sd0, 8'sd1, 8'sd0, 8'sd0, 8'sd0,
            8'sd0, 8'sd0, 8'sd1, 8'sd0, 8'sd0,
            8'sd0, 8'sd0, 8'sd0, 8'sd1, 8'sd0,
            8'sd0, 8'sd0, 8'sd0, 8'sd0, 8'sd2
        };
        #10;
        $display("Teste 1 - Esperado: 2, Obtido: %d", det);

        // Teste 2: Linha repetida → determinante esperado: 0
        matriz_5x5 = {
            8'sd1, 8'sd2, 8'sd3, 8'sd4, 8'sd5,
            8'sd1, 8'sd2, 8'sd3, 8'sd4, 8'sd5,
            8'sd6, 8'sd7, 8'sd8, 8'sd9, 8'sd0,
            8'sd0, 8'sd0, 8'sd0, 8'sd0, 8'sd0,
            8'sd1, 8'sd1, 8'sd1, 8'sd1, 8'sd1
        };
        #10;
        $display("Teste 2 - Esperado: 0, Obtido: %d", det);

        // Teste 3: Matriz triangular superior → determinante esperado: 720
        matriz_5x5 = {
            8'sd2, 8'sd1, 8'sd0, 8'sd0, 8'sd0,
            8'sd0, 8'sd3, 8'sd1, 8'sd0, 8'sd0,
            8'sd0, 8'sd0, 8'sd4, 8'sd1, 8'sd0,
            8'sd0, 8'sd0, 8'sd0, 8'sd5, 8'sd1,
            8'sd0, 8'sd0, 8'sd0, 8'sd0, 8'sd6
        };
        #10;
        $display("Teste 3 - Esperado: 720, Obtido: %d", det);

        $finish;
    end

endmodule
