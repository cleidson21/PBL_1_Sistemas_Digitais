`timescale 1ns/1ps

module tb_soma_matrizes;

    reg signed [199:0] matriz_a;
    reg signed [199:0] matriz_b;
    wire signed [199:0] matriz_result;
    wire overflow;
    
    // Instancia o módulo de soma de matrizes
    MatrixAdder uut (
        .matrix_A(matriz_a),
        .matrix_B(matriz_b),
        .result_out(matriz_result),
        .overflow(overflow)
    );
    
    integer i, j;
    
    initial begin
        // Inicializa a matriz A com valores de -10 a 14
        matriz_a = { 
            8'sd10, 8'sd9, 8'sd8, 8'sd7, 8'sd6,
            8'sd5,  8'sd4, 8'sd3, 8'sd2, 8'sd1,
            8'sd0,   8'sd1,  8'sd2,  8'sd3,  8'sd4,
            8'sd5,   8'sd6,  8'sd7,  8'sd8,  8'sd9,
            8'sd10,  8'sd11, 8'sd12, 8'sd13, 8'sd14
        };
        
        // Inicializa a matriz B com valores de 10 a -14
        matriz_b = { 
            8'sd10,  8'sd9,  8'sd8,  8'sd7,  8'sd6,
            8'sd5,   8'sd4,  8'sd3,  8'sd2,  8'sd1,
            8'sd0,   8'sd1, 8'sd2, 8'sd3, 8'sd4,
            8'sd5,  8'sd6, 8'sd7, 8'sd8, 8'sd9,
            8'sd10, 8'sd11,8'sd12,8'sd13,8'sd14
        };
        
        #10; // Aguarda a propagação dos sinais
        
        // Exibe os resultados
        $display("Matriz A:");
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                $write("%d ", matriz_a[(i * 5 + j) * 8 +: 8]);
            end
            $display;
        end
        
        $display("Matriz B:");
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                $write("%d ", matriz_b[(i * 5 + j) * 8 +: 8]);
            end
            $display;
        end
        
        $display("Matriz Resultado (A + B):");
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                $write("%d ", matriz_result[(i * 5 + j) * 8 +: 8]);
            end
            $display;
        end
        
        // Verifica se houve overflow
        if (overflow)
            $display("⚠️ Overflow detectado!");
        else
            $display("✅ Nenhum overflow detectado.");
        
        $finish;
    end

endmodule
