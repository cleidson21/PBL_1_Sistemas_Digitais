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

    // Determinante 5x5
    determinante_5x5 det_calculator (
        .clk(clk),
        .reset(rst),
        .start(start),
        .matrix_00(matrix_a[7:0]),     .matrix_01(matrix_a[15:8]),    .matrix_02(matrix_a[23:16]),   .matrix_03(matrix_a[31:24]),  .matrix_04(matrix_a[39:32]),
        .matrix_10(matrix_a[47:40]),   .matrix_11(matrix_a[55:48]),   .matrix_12(matrix_a[63:56]),   .matrix_13(matrix_a[71:64]),  .matrix_14(matrix_a[79:72]),
        .matrix_20(matrix_a[87:80]),   .matrix_21(matrix_a[95:88]),   .matrix_22(matrix_a[103:96]),  .matrix_23(matrix_a[111:104]),.matrix_24(matrix_a[119:112]),
        .matrix_30(matrix_a[127:120]), .matrix_31(matrix_a[135:128]), .matrix_32(matrix_a[143:136]), .matrix_33(matrix_a[151:144]),.matrix_34(matrix_a[159:152]),
        .matrix_40(matrix_a[167:160]), .matrix_41(matrix_a[175:168]), .matrix_42(matrix_a[183:176]), .matrix_43(matrix_a[191:184]),.matrix_44(matrix_a[199:192]),
        .determinant(determinant_result),
        .done(determinant_done)
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
