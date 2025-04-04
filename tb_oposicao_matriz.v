

`timescale 1ns/1ps

module tb_oposicao_matriz;

    reg signed [199:0] matrix_A;           // Matriz original
    wire signed [199:0] m_oposta_A;        // Matriz oposta

    // Instancia o módulo de oposição
    oposicao_matriz uut (
        .matrix_A(matrix_A),
        .m_oposta_A(m_oposta_A)
    );

    integer i, j;

    initial begin
        $display("Iniciando Teste da Oposição de Matriz");

        // Matriz com valores positivos e negativos
        matrix_A = { 
             8'sd1,   8'sd2,  8'sd3,   8'sd4,  8'sd5,
             8'sd6,  8'sd7,   8'sd8,  8'sd9,   8'sd10,
             8'sd11,  8'sd12, 8'sd13,  8'sd14, 8'sd15,
             8'sd16, 8'sd17,  8'sd18, 8'sd19,  8'sd20,
             8'sd21,  8'sd22, 8'sd23,  8'sd24, 8'sd25
        };

        #10; // Espera um tempo para a propagação

        $display("Matriz Original (5x5):");
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                $write("%4d ", matrix_A[(i * 5 + j) * 8 +: 8]);
            end
            $display;
        end

        $display("Matriz Oposta (5x5):");
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                $write("%4d ", m_oposta_A[(i * 5 + j) * 8 +: 8]);
            end
            $display;
        end

        $display("Teste concluído!");
        $finish;
    end

endmodule
