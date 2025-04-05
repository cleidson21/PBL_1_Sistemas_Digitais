
`timescale 1ns/1ps

module tb_MatrixSubtractor;

    reg signed [199:0] matrix_A;
    reg signed [199:0] matrix_B;
    wire signed [199:0] result_out;
    wire overflow;

    // Instancia o módulo de subtração
    MatrixSubtractor uut (
        .matrix_A(matrix_A),
        .matrix_B(matrix_B),
        .result_out(result_out),
        .overflow(overflow)
    );
    
    integer i, j;
    
    initial begin
        $display("Iniciando Teste da Subtração de Matrizes");
        
        // Caso 1: Teste com números positivos
        matrix_A = { 
            8'd10,  8'd20,  8'd30,  8'd40,  8'd50,
            8'd60,  8'd70,  8'd80,  8'd90,  8'd100,
            8'd110, 8'd120, 8'd130, 8'd140, 8'd150,
            8'd160, 8'd170, 8'd180, 8'd190, 8'd200,
            8'd210, 8'd220, 8'd230, 8'd240, 8'd250 
        };
        
        matrix_B = { 
            8'd1,  8'd2,  8'd3,  8'd4,  8'd5,
            8'd6,  8'd7,  8'd8,  8'd9,  8'd10,
            8'd11, 8'd12, 8'd13, 8'd14, 8'd15,
            8'd16, 8'd17, 8'd18, 8'd19, 8'd20,
            8'd21, 8'd22, 8'd23, 8'd24, 8'd25 
        };
        
        #10;
        $display("Caso 1 - Matriz A:");
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                $write("%d ", matrix_A[(i * 5 + j) * 8 +: 8]);
            end
            $display;
        end

        $display("Caso 1 - Matriz B:");
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                $write("%d ", matrix_B[(i * 5 + j) * 8 +: 8]);
            end
            $display;
        end

        $display("Caso 1 - Resultado A - B:");
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                $write("%d ", result_out[(i * 5 + j) * 8 +: 8]);
            end
            $display;
        end
        $display("Overflow: %b", overflow);

        // Caso 2: Teste com números negativos
        for (i = 0; i < 25; i = i + 1) begin
            matrix_A[i * 8 +: 8] = -5 * (i + 1);
            matrix_B[i * 8 +: 8] = -1 * (i + 1);
        end
        
        #10;
        $display("Caso 2 - Matriz A:");
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                $write("%d ", matrix_A[(i * 5 + j) * 8 +: 8]);
            end
            $display;
        end

        $display("Caso 2 - Matriz B:");
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                $write("%d ", matrix_B[(i * 5 + j) * 8 +: 8]);
            end
            $display;
        end

        $display("Caso 2 - Resultado A - B (Negativos):");
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                $write("%d ", result_out[(i * 5 + j) * 8 +: 8]);
            end
            $display;
        end
        $display("Overflow: %b", overflow);

        // Caso 3: Teste de Overflow
        for (i = 0; i < 25; i = i + 1) begin
            matrix_A[i * 8 +: 8] = 127;
            matrix_B[i * 8 +: 8] = -128;
        end
        
        #10;
        $display("Caso 3 - Matriz A:");
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                $write("%d ", matrix_A[(i * 5 + j) * 8 +: 8]);
            end
            $display;
        end

        $display("Caso 3 - Matriz B:");
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                $write("%d ", matrix_B[(i * 5 + j) * 8 +: 8]);
            end
            $display;
        end

        $display("Caso 3 - Teste de Overflow:");
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                $write("%d ", result_out[(i * 5 + j) * 8 +: 8]);
            end
            $display;
        end
        $display("Overflow: %b", overflow);
        
        $display("Teste concluído!");
        $finish;
    end

endmodule
