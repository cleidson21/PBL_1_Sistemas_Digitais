`timescale 1ns/1ps

module determinante_tb;
    reg signed [199:0] matriz;
    reg [1:0] sinalizador;
    wire signed [31:0] det;

    // Instancia o módulo a ser testado
    determinante uut (
        .matriz(matriz),
        .sinalizador(sinalizador),
        .det(det)
    );

    initial begin
        // Teste 1: Matriz 2x2
        sinalizador = 2'b00;
        matriz = {168'b0, 8'd3, -8'd2, 8'd4, -8'd1}; // [3 -2]
                                                    // [4 -1]
        #10;
        $display("Det 2x2: %d", det);

        // Teste 2: Matriz 3x3
        sinalizador = 2'b01;
        matriz = {128'b0, 8'd6, -8'd1, 8'd3, 8'd4, -8'd2, 8'd5, 8'd9, 8'd0, -8'd6};
        #10;
        $display("Det 3x3: %d", det);

        // Teste 3: Matriz 4x4
        sinalizador = 2'b10;
        matriz = {72'b0, 8'd1, 8'd2, -8'd3, 8'd4, -8'd5, 8'd6, 8'd7, -8'd8, 
                          8'd9, -8'd10, 8'd11, 8'd12, -8'd13, 8'd14, -8'd15, 8'd16};
        #10;
        $display("Det 4x4: %d", det);

        // Teste 4: Matriz 5x5
        sinalizador = 2'b11;
        matriz = {8'd1, -8'd2, 8'd3, -8'd4, 8'd5, 8'd6, -8'd7, 8'd8, -8'd9, 8'd10, 
                  -8'd11, 8'd12, 8'd13, -8'd14, 8'd15, 8'd16, 8'd17, -8'd18, 8'd19, -8'd20, 
                   8'd21, 8'd22, -8'd23, 8'd24, -8'd25};
        #10;
        $display("Det 5x5: %d", det);

        $finish;
    end
endmodule
