module Alu (
    input wire [2:0] op_code,                   // Código da operação a ser executada (adição, subtração, etc.)
    input wire [1:0] matrix_size,               // Define o tamanho da matriz (2x2, 3x3, 4x4, 5x5)
    input signed [199:0] matrix_a,              // Matriz A de entrada
    input signed [199:0] matrix_b,              // Matriz B de entrada
    input signed [7:0] scalar,                  // Valor escalar para multiplicação
    output reg overflow,                        // Sinaliza overflow em operações
    output reg process_Done,                    // Sinaliza que o processamento foi concluído
    output reg signed [199:0] result_final,     // Resultado final da operação
    input wire clk,                             // Clock de entrada
    input wire rst,                             // Sinal de reset
    input wire start                            // Sinal de início da operação
);

    // Resultados intermediários para cada operação
    wire signed [199:0] result_add, result_sub, result_transpose, result_opposite, result_mult_esc, result_matrix_mult;
    wire overflow_add, overflow_sub, overflow_matrix_mult;
    wire signed [7:0] determinant_result;      
    wire determinant_done, matrix_mult_done;   

   // Instância dos módulos combinacionais que realizam as operações de matriz
   MatrixAdder adder (
        .matrix_A(matrix_a),
        .matrix_B(matrix_b),
        .matrix_size(matrix_size),
        .result_out(result_add),             // Resultado da adição
        .overflow(overflow_add)              // Sinal de overflow na adição
    );

   MatrixSubtractor subtractor (
        .matrix_A(matrix_a),
        .matrix_B(matrix_b),
        .matrix_size(matrix_size),
        .result_out(result_sub),             // Resultado da subtração
        .overflow(overflow_sub)              // Sinal de overflow na subtração
    );

    transposicao_matriz transpose (
        .matrix_A(matrix_a),                  // Matriz A de entrada
        .matrix_size(matrix_size),            // Tamanho da matriz
        .m_transposta_A(result_transpose)     // Matriz transposta (resultado)
    );

    oposicao_matriz opposite (
        .matrix_A(matrix_a),                  // Matriz A de entrada
        .matrix_size(matrix_size),            // Tamanho da matriz
        .m_oposta_A(result_opposite)          // Matriz oposta (resultado)
    );

    multiplicacao_num_matriz multiplierScalar (
        .matriz_A(matrix_a),                  // Matriz A
        .matrix_size(matrix_size),            // Tamanho da matriz
        .num_inteiro(scalar),                 // Escalar para multiplicação
        .nova_matriz_A(result_mult_esc)       // Resultado da multiplicação escalar
    );

    // Módulo sequencial para multiplicação de matrizes
    multiplicacao matrix_multiplier (
        .clk(clk),                            // Clock de entrada
        .start(start),                        // Inicia a operação de multiplicação
        .matriz_a(matrix_a),                  // Matriz A
        .matriz_b(matrix_b),                  // Matriz B
        .matriz_result(result_matrix_mult),   // Resultado da multiplicação de matrizes
        .done(matrix_mult_done),              // Sinal de operação finalizada
        .overflow_global(overflow_matrix_mult) // Sinal de overflow na multiplicação de matrizes
    );

    // Módulo para cálculo do determinante da matriz
    ula_determinante determinante_matriz (
        .clk(clk),                            // Clock de entrada
        .matriz(matrix_a),                    // Matriz para calcular o determinante
        .tamanho_matriz(matrix_size),         // Tamanho da matriz
        .det(determinant_result),             // Resultado do determinante
        .done(determinant_done)               // Sinaliza que o determinante foi calculado
    );

    // Lógica de controle para selecionar a operação a ser realizada com base no código de operação (op_code)
    always @(*) begin
        case (op_code)
            3'b000: begin 
                result_final = result_add;            // Resultado da adição de matrizes
                overflow = overflow_add;              // Propaga o sinal de overflow da adição
                process_Done = 1;                     // Indica que o processamento está concluído
            end
            3'b001: begin 
                result_final = result_sub;            // Resultado da subtração de matrizes
                overflow = overflow_sub;              // Propaga o sinal de overflow da subtração
                process_Done = 1;                     // Indica que o processamento está concluído
            end
            3'b010: begin 
                result_final = result_transpose;      // Resultado da transposição da matriz
                overflow = 0;                         // Não há overflow em transposição
                process_Done = 1;                     // Indica que o processamento está concluído
            end
            3'b011: begin 
                result_final = result_opposite;       // Resultado da matriz oposta
                overflow = 0;                         // Não há overflow em operação de oposto
                process_Done = 1;                     // Indica que o processamento está concluído
            end
            3'b100: begin 
                result_final = result_mult_esc;       // Resultado da multiplicação escalar
                overflow = 0;                         // Não há overflow na multiplicação escalar
                process_Done = 1;                     // Indica que o processamento está concluído
            end
            3'b101: begin
                if (determinant_done) begin
                    result_final = determinant_result;  // Zera os bits superiores no cálculo do determinante
                    overflow = 0;                       // Não há overflow no determinante
                    process_Done = 1;                   // Indica que o processamento foi concluído
                end else begin
                    result_final = 0;                   // Se o determinante não foi calculado, limpa o resultado
                    overflow = 0;                       // Não há overflow se não houver cálculo
                    process_Done = 0;                   // Indica que o processamento não foi concluído
                end
            end
            3'b110: begin
                if (matrix_mult_done) begin
                    result_final = result_matrix_mult;   // Resultado da multiplicação de matrizes
                    overflow = overflow_matrix_mult;     // Propaga o sinal de overflow da multiplicação de matrizes
                    process_Done = 1;                    // Indica que o processamento foi concluído
                end else begin
                    result_final = 0;                    // Se a multiplicação não estiver concluída, limpa o resultado
                    overflow = 0;                        // Não há overflow se a multiplicação não estiver concluída
                    process_Done = 0;                    // Indica que o processamento não foi concluído
                end     
            end
            default: begin 
                result_final = 0;                       // Caso padrão, limpa o resultado
                overflow = 0;                           // Não há overflow
                process_Done = 0;                       // Processamento não concluído
            end
        endcase
    end

endmodule
