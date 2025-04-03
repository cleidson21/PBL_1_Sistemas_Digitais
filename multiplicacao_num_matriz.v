// Módulo combinacional para multiplicar um número inteiro por uma matriz
module multiplicacao_num_matriz (
    input signed [199:0] matriz_A,  						// Matriz A de entrada (25 elementos de 8 bits)
    input signed [7:0] num_inteiro, 						// Número escalar (8 bits)
    output signed [199:0] nova_matriz_A 				 	// Matriz resultante da multiplicação
);

    wire signed [7:0] matriz_original [0:24];  			// Elementos da matriz original
    wire signed [7:0] matriz_multiplicada [0:24];  	// Elementos multiplicados

    genvar i;
    generate
        for (i = 0; i < 25; i = i + 1) begin : multiplicacao
            assign matriz_original[i] = matriz_A[(i << 3) +: 8];  			// Extraí cada elemento de 8 bits
            multiplicar_elemento mult (
                .elemento(matriz_original[i]),  									// Elemento da matriz A
                .num(num_inteiro),              									// Número escalar para multiplicação
                .resultado(matriz_multiplicada[i]) 								// Resultado da multiplicação
            );
            assign nova_matriz_A[(i << 3) +: 8] = matriz_multiplicada[i];  // Atribui resultado à nova matriz
        end
    endgenerate

endmodule

// Módulo recursivo para multiplicar um elemento da matriz
module multiplicar_elemento (
    input signed [7:0] elemento,  						// Elemento da matriz A
    input signed [7:0] num,       						// Número escalar para multiplicação
    output signed [7:0] resultado  						// Resultado da multiplicação
);
    assign resultado = elemento * num;  				// Realiza a multiplicação
endmodule
