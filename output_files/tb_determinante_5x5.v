

`timescale 1ns/1ps

module tb_determinante_5x5;

    reg clk;
    reg reset;
    reg start;
    reg [7:0] matrix_00, matrix_01, matrix_02, matrix_03, matrix_04;
    reg [7:0] matrix_10, matrix_11, matrix_12, matrix_13, matrix_14;
    reg [7:0] matrix_20, matrix_21, matrix_22, matrix_23, matrix_24;
    reg [7:0] matrix_30, matrix_31, matrix_32, matrix_33, matrix_34;
    reg [7:0] matrix_40, matrix_41, matrix_42, matrix_43, matrix_44;
    wire [39:0] determinant;
    wire done;

    // Instancia o módulo a ser testado
    determinante_5x5 uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .matrix_00(matrix_00), .matrix_01(matrix_01), .matrix_02(matrix_02), .matrix_03(matrix_03), .matrix_04(matrix_04),
        .matrix_10(matrix_10), .matrix_11(matrix_11), .matrix_12(matrix_12), .matrix_13(matrix_13), .matrix_14(matrix_14),
        .matrix_20(matrix_20), .matrix_21(matrix_21), .matrix_22(matrix_22), .matrix_23(matrix_23), .matrix_24(matrix_24),
        .matrix_30(matrix_30), .matrix_31(matrix_31), .matrix_32(matrix_32), .matrix_33(matrix_33), .matrix_34(matrix_34),
        .matrix_40(matrix_40), .matrix_41(matrix_41), .matrix_42(matrix_42), .matrix_43(matrix_43), .matrix_44(matrix_44),
        .determinant(determinant),
        .done(done)
    );

    // Clock de 10ns
    always #5 clk = ~clk;

    initial begin
        $display("Iniciando Teste do Determinante 5x5");
        clk = 0;
        reset = 1;
        start = 0;

        // Matriz de exemplo
        matrix_00 = 1;  matrix_01 = 2;  matrix_02 = 3;  matrix_03 = 4;  matrix_04 = 5;
        matrix_10 = 6;  matrix_11 = 7;  matrix_12 = 8;  matrix_13 = 9;  matrix_14 = 10;
        matrix_20 = 11; matrix_21 = 12; matrix_22 = 13; matrix_23 = 14; matrix_24 = 15;
        matrix_30 = 16; matrix_31 = 17; matrix_32 = 18; matrix_33 = 19; matrix_34 = 20;
        matrix_40 = 21; matrix_41 = 22; matrix_42 = 23; matrix_43 = 24; matrix_44 = 25;

        #10 reset = 0; // Sai do reset
        #10 start = 1; // Inicia o cálculo
        #10 start = 0; // Retorna start a 0

        // Espera a conclusão do cálculo
        wait(done);

        // Exibe resultado
        $display("Determinante calculado: %d", determinant);

        // Finaliza simulação
        $finish;
    end
endmodule
