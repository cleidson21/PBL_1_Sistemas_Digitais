

`timescale 1ns/1ps

module tb_multiplicacao_num_matriz;

    reg signed [199:0] matriz_A;              // Matriz original (25 elementos de 8 bits)
    reg signed [7:0] num_inteiro;             // Escalar para multiplicação
    wire signed [199:0] nova_matriz_A;        // Matriz resultante

    integer i, j;

    // Instancia o módulo principal
    multiplicacao_num_matriz uut (
        .matriz_A(matriz_A),
        .num_inteiro(num_inteiro),
        .nova_matriz_A(nova_matriz_A)
    );

    initial begin
        $display("Iniciando Teste da Multiplicação Escalar por Matriz");

        // Matriz de teste com valores variados
        matriz_A = {
            8'sd1,   8'sd2,  8'sd3,   8'sd4,  8'sd5,
            8'sd6,  8'sd7,   8'sd8,  8'sd9,   8'sd10,
            8'sd11,  8'sd12, 8'sd13,  8'sd14, 8'sd15,
            8'sd16, 8'sd17,  8'sd18, 8'sd19,  8'sd20,
            8'sd21,  8'sd22, 8'sd23,  8'sd24, 8'sd25
        };

        num_inteiro = 8'sd3; // Multiplicar cada elemento por 3

        #10; // Espera para propagação de sinais

        $display("Matriz Original:");
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                $write("%4d ", matriz_A[(i * 5 + j) * 8 +: 8]);
            end
            $display;
        end

        $display("Número Escalar: %d", num_inteiro);

        $display("Matriz Após Multiplicação Escalar:");
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                $write("%4d ", nova_matriz_A[(i * 5 + j) * 8 +: 8]);
            end
            $display;
        end

        $display("Teste concluído!");
        $finish;
    end

endmodule
