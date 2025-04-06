module Alu (
    input wire [2:0] op_code,
    input signed [199:0] matrix_a,
    input signed [199:0] matrix_b,
    input signed [7:0] scalar,
    output reg overflow,
    output reg signed [199:0] result_final,
    input wire clk,
    input wire rst,
    input wire start
);

    // Resultados dos módulos
    wire signed [199:0] result_add, result_sub, result_transpose, result_opposite, result_mult_esc, result_matrix_mult;
    wire overflow_add, overflow_sub, overflow_matrix_mult;
    wire signed [39:0] determinant_result;
    wire determinant_done;
    wire matrix_mult_done;

    // Módulos combinacionais
    MatrixAdder adder (
        .matrix_A(matrix_a),
        .matrix_B(matrix_b),
        .result_out(result_add),
        .overflow(overflow_add)
    );

    MatrixSubtractor subtractor (
        .matrix_A(matrix_a),
        .matrix_B(matrix_b),
        .result_out(result_sub),
        .overflow(overflow_sub)
    );

    transposicao_matriz transpose (
        .matrix_A(matrix_a),
        .m_transposta_A(result_transpose)
    );

    oposicao_matriz opposite (
        .matrix_A(matrix_a),
        .m_oposta_A(result_opposite)
    );

    multiplicacao_num_matriz multiplierScalar (
        .matriz_A(matrix_a),
        .num_inteiro(scalar),
        .nova_matriz_A(result_mult_esc)
    );

    // Módulo sequencial de multiplicação de matrizes
    multiplicacao matrix_multiplier (
        .clk(clk),
        .start(start),
        .matriz_a(matrix_a),
        .matriz_b(matrix_b),
        .matriz_result(result_matrix_mult),
        .done(matrix_mult_done),
        .overflow_global(overflow_matrix_mult)
    );

    // Lógica para seleção de operação
    always @(*) begin
        case (op_code)
            3'b000: begin 
                result_final = result_add;
                overflow = overflow_add;
            end
            3'b001: begin 
                result_final = result_sub;
                overflow = overflow_sub;
            end
            3'b010: begin 
                result_final = result_transpose;
                overflow = 0;
            end
            3'b011: begin 
                result_final = result_opposite;
                overflow = 0;
            end
            3'b100: begin 
                result_final = result_mult_esc;
                overflow = 0;
            end
            3'b101: begin
                if (determinant_done) begin
                    result_final = determinant_result;
                    overflow = 0;
                end else begin
                    result_final = 0;
                    overflow = 0;
                end
            end
            3'b110: begin
                if (matrix_mult_done) begin
                    result_final = result_matrix_mult;
                    overflow = overflow_matrix_mult;
                end else begin
                    result_final = 0;
                    overflow = 0;
                end
            end
            default: begin 
                result_final = 0;
                overflow = 0;
            end
        endcase
    end

endmodule
