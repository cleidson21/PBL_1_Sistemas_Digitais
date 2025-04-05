
`timescale 1ns/1ps

module tb_transposicao_matriz;

    reg signed [199:0] matrix_A;           // Matriz original (5x5)
    wire signed [199:0] m_transposta_A;    // Matriz transposta

    // Instancia o módulo de transposição
    transposicao_matriz uut (
        .matrix_A(matrix_A),
        .m_transposta_A(m_transposta_A)
    );

    integer i, j;

    initial begin
        $display("Iniciando Teste de Transposição de Matriz");

        // Inicializa a matriz A com valores sequenciais
        matrix_A = { 
            8'd1,  8'd2,  8'd3,  8'd4,  8'd5,
            8'd6,  8'd7,  8'd8,  8'd9,  8'd10,
            8'd11, 8'd12, 8'd13, 8'd14, 8'd15,
            8'd16, 8'd17, 8'd18, 8'd19, 8'd20,
            8'd21, 8'd22, 8'd23, 8'd24, 8'd25
        };

        #10; // Espera um tempo para atualizar os sinais

        $display("Matriz Original (5x5):");
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                $write("%d ", matrix_A[(i * 5 + j) * 8 +: 8]);
            end
            $display;
        end

        $display("Matriz Transposta (5x5):");
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                $write("%d ", m_transposta_A[(i * 5 + j) * 8 +: 8]);
            end
            $display;
        end

        $display("Teste concluído!");
        $finish;
    end

endmodule
