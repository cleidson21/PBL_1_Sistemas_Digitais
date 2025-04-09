module Alu (
    input wire [2:0] op_code,          			// Código de operação que determina qual operação será executada
    input signed [199:0] matrix_a,     			// Matriz A de entrada, com 200 bits (matriz 5x5 de inteiros de 8 bits com sinal)
    input signed [199:0] matrix_b,     			// Matriz B de entrada, com 200 bits (matriz 5x5 de inteiros de 8 bits com sinal)
    input signed [7:0] scalar,         			// Escalar para multiplicação da matriz A
    output reg overflow,              				// Indicador de overflow, para todas as operações
    output reg signed [199:0] result_final,  	// Resultado final da operação
    input wire clk,                   				// Sinal de clock para a operação sequencial
    input wire rst,                    			// Sinal de reset para reiniciar a operação
    input wire start                   			// Sinal para iniciar o cálculo da determinante
);

    // Resultados dos módulos de operações
    wire signed [199:0] result_add, result_sub, result_transpose, result_opposite, result_mult;  // Resultados das operações
    wire overflow_add, overflow_sub, overflow_transpose, overflow_opposite;  // Flags de overflow para as operações
    wire signed [39:0] determinant_result;  				// Resultado da determinante (40 bits)
    wire determinant_done;           				// Sinal que indica que o cálculo da determinante terminou

    // Instanciação dos módulos de operação para adição e subtração de matrizes, transposição e oposição
    MatrixAdder adder (
        .matrix_A(matrix_a),
        .matrix_B(matrix_b),
        .result_out(result_add),  					// Resultado da adição das matrizes A e B
        .overflow(overflow_add)  					// Flag de overflow para a operação de adição
    );

    MatrixSubtractor subtractor (
        .matrix_A(matrix_a),
        .matrix_B(matrix_b),
        .result_out(result_sub),  					// Resultado da subtração das matrizes A e B
        .overflow(overflow_sub)   					// Flag de overflow para a operação de subtração
    );	

    transposicao_matriz transpose (
        .matrix_A(matrix_a),
        .m_transposta_A(result_transpose)  		// Resultado da transposição da matriz A
    );
    
    oposicao_matriz opposite (
        .matrix_A(matrix_a),
        .m_oposta_A(result_opposite)  				// Resultado da oposição (negativo) da matriz A
    );
    
    multiplicacao_num_matriz multiplierScalar (
        .matriz_A(matrix_a),
        .num_inteiro(scalar),
        .nova_matriz_A(result_mult)  				// Resultado da multiplicação de A pelo escalar
    );
    
    // Instanciação do módulo de cálculo da determinante 5x5
    determinante_5x5 det_calculator (
        .clk(clk),           // Clock para sincronização
        .reset(rst),         // Reset para reiniciar o cálculo
        .start(start),       // Sinal para iniciar o cálculo da determinante
        // Mapeamento dos elementos da matriz 5x5 (extração dos elementos de 8 bits da matriz A)
        .matrix_00(matrix_a[7:0]), .matrix_01(matrix_a[15:8]), .matrix_02(matrix_a[23:16]), .matrix_03(matrix_a[31:24]), .matrix_04(matrix_a[39:32]),
        .matrix_10(matrix_a[47:40]), .matrix_11(matrix_a[55:48]), .matrix_12(matrix_a[63:56]), .matrix_13(matrix_a[71:64]), .matrix_14(matrix_a[79:72]),
        .matrix_20(matrix_a[87:80]), .matrix_21(matrix_a[95:88]), .matrix_22(matrix_a[103:96]), .matrix_23(matrix_a[111:104]), .matrix_24(matrix_a[119:112]),
        .matrix_30(matrix_a[127:120]), .matrix_31(matrix_a[135:128]), .matrix_32(matrix_a[143:136]), .matrix_33(matrix_a[151:144]), .matrix_34(matrix_a[159:152]),
        .matrix_40(matrix_a[167:160]), .matrix_41(matrix_a[175:168]), .matrix_42(matrix_a[183:176]), .matrix_43(matrix_a[191:184]), .matrix_44(matrix_a[199:192]),
        .determinant(determinant_result),  // Resultado da determinante (40 bits)
        .done(determinant_done)            // Sinal que indica que o cálculo da determinante foi concluído
    );
    
    // Bloco sempre que escolhe qual operação realizar com base no código de operação
    always @(*) begin
        case (op_code)
            3'b000: begin 
                result_final = result_add;  					// Adição de matrizes
                overflow = overflow_add;    					// Sinal de overflow da adição
            end
            3'b001: begin 
                result_final = result_sub;  					// Subtração de matrizes
                overflow = overflow_sub;    					// Sinal de overflow da subtração
            end
            3'b010: begin 
                result_final = result_transpose;   		// Transposição da matriz A
                overflow = 0;  									// Não há overflow na transposição
            end
            3'b011: begin 
                result_final = result_opposite;  			// Oposição (negativo) da matriz A
                overflow = 0;  									// Não há overflow na oposição
            end
            3'b100: begin 
                result_final = result_mult;  				// Multiplicação da matriz A pelo escalar
                overflow = 0;  									// Não há overflow na multiplicação por escalar
            end
            3'b101: begin  // Cálculo da determinante
                if (determinant_done) begin
                    result_final = determinant_result;  	// Resultado da determinante
                    overflow = 0;  								// Não há overflow esperado, o resultado é de 40 bits
                end else begin
                    result_final = 0;  						// Enquanto o cálculo não terminar, o resultado será 0
                    overflow = 0;  								// Não há overflow enquanto o cálculo não é concluído
                end
            end
            default: begin 
                result_final = 0; 							 	// Caso padrão (não reconhecido)
                overflow = 0;      								// Sem overflow
            end
        endcase
    end

endmodule
