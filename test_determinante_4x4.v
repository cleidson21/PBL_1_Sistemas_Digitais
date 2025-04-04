`timescale 1ns / 1ps

module tb_determinante_4x4;

    reg signed [127:0] matriz_4x4;
    wire signed [31:0] det;

    // Instancia o módulo determinante_4x4
    determinante_4x4 uut (
        .matriz_4x4(matriz_4x4),
        .det(det)
    );

    initial begin
        // Matriz exemplo:
        // | 1  0  2 -1 |
        // | 3  0  0  5 |
        // | 2  1  4 -3 |
        // | 1  0  5  0 |
        // Determinante esperado: 30

        matriz_4x4 = {
            8'sd1,  8'sd0,  8'sd2, -8'sd1,
            8'sd3,  8'sd0,  8'sd0,  8'sd5,
            8'sd2,  8'sd1,  8'sd4, -8'sd3,
            8'sd1,  8'sd0,  8'sd5,  8'sd0
        };

        #10;
        $display("Determinante da matriz 4x4 = %d", det);

        $finish;
    end

endmodule
