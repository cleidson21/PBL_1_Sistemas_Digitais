`timescale 1ns / 1ps

module tb_determinante_3x3;

    reg signed [71:0] matriz_3x3;
    wire signed [31:0] det;

    // Instância do módulo que queremos testar
    determinante_3x3 uut (
        .matriz_3x3(matriz_3x3),
        .det(det)
    );

    initial begin
        // Exemplo de matriz:
        // | 1  2  3 |
        // | 4  5  6 |
        // | 7  8  9 |
        // Esperado: determinante = 0

        matriz_3x3 = {
            8'sd1, 8'sd2, 8'sd3,
            8'sd4, 8'sd5, 8'sd6,
            8'sd7, 8'sd8, 8'sd9
        };

        #10;
        $display("Determinante da matriz 3x3 = %d", det);

        // Outro teste:
        // | 1  0  2 |
        // | -1 3  1 |
        // | 3  1  0 |
        // Esperado: det = 1*(3*0 - 1*1) - 0*(-1*0 - 1*3) + 2*(-1*1 - 3*3)
        // det = 1*(0 - 1) - 0*(0 - 3) + 2*(-1 - 9) = -1 + 0 + 2*(-10) = -1 - 20 = -21

        matriz_3x3 = {
            8'sd1, 8'sd0, 8'sd2,
            -8'sd1, 8'sd3, 8'sd1,
            8'sd3, 8'sd1, 8'sd0
        };

        #10;
        $display("Determinante da matriz 3x3 = %d", det);

        $finish;
    end

endmodule
