module ula_determinante(
    input clk,
    input signed [199:0] matriz,
    input [1:0] tamanho_matriz, 
    output reg signed [7:0] det,
    output reg done
);

    // Saídas intermediárias dos módulos
    wire signed [7:0] det_2x2, det_3x3, det_4x4;

    // Instanciação dos módulos
    determinante_2x2 u0 (.matriz_2x2(matriz[31:0]), .det(det_2x2));
    determinante_3x3 u1 (.matriz_3x3(matriz[71:0]), .det(det_3x3));
	 determinante_4x4 u2 (.A(matriz[127:0]), .det(det_4x4));

    // Multiplexação da saída correta
    always @(posedge clk) begin
        case (tamanho_matriz)
            2'b00: det <= det_2x2;
            2'b01: det <= det_3x3;
				2'b10: det <= det_4x4;
            default: det <= 0;
        endcase
        done <= 1'b1; // Indica que o cálculo foi concluído
    end

endmodule
