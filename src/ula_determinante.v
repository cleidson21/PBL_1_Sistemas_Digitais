module ula_determinante(
    input signed [199:0] matriz,
    input [1:0] sinalizador, 
    output reg signed [7:0] det
);

    // Saídas intermediárias dos módulos
    wire signed [7:0] det_2x2, det_3x3;
	 // wire signed [7:0] det_4x4, det_5x5;

    // Instanciação dos módulos
    determinante_2x2 u0 (.matriz_2x2(matriz[31:0]), .det(det_2x2));
    determinante_3x3 u1 (.matriz_3x3(matriz[71:0]), .det(det_3x3));
    // determinante_4x4 u2 (.matriz_4x4(matriz[127:0]), .det(det_4x4)); FALTA TERMINAR
    // determinante_5x5 u3 (.matriz_5x5(matriz[199:0]), .det(det_5x5)); FALTA TERMINAR

    // Multiplexação da saída correta
    always @(*) begin
        case (sinalizador)
            2'b00: det = det_2x2;
            2'b01: det = det_3x3;
            // 2'b10: det = det_4x4;
            // 2'b11: det = det_5x5;
            default: det = 0;
        endcase
    end

endmodule