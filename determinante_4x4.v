module determinante_4x4 (
    input signed [127:0] matriz_4x4, // Matriz 4x4 compactada (16 elementos de 8 bits cada)
    output reg signed [31:0] det // Resultado do determinante
);
    
    wire signed [7:0] a = matriz_4x4[127:120];
    wire signed [7:0] b = matriz_4x4[119:112];
    wire signed [7:0] c = matriz_4x4[111:104];
    wire signed [7:0] d = matriz_4x4[103:96];
    wire signed [7:0] e = matriz_4x4[95:88];
    wire signed [7:0] f = matriz_4x4[87:80];
    wire signed [7:0] g = matriz_4x4[79:72];
    wire signed [7:0] h = matriz_4x4[71:64];
    wire signed [7:0] i = matriz_4x4[63:56];
    wire signed [7:0] j = matriz_4x4[55:48];
    wire signed [7:0] k = matriz_4x4[47:40];
    wire signed [7:0] l = matriz_4x4[39:32];
    wire signed [7:0] m = matriz_4x4[31:24];
    wire signed [7:0] n = matriz_4x4[23:16];
    wire signed [7:0] o = matriz_4x4[15:8];
    wire signed [7:0] p = matriz_4x4[7:0];
    
    wire signed [31:0] det3_1, det3_2, det3_3, det3_4;
    
    determinante_3x3 det3x3_1 ({f, g, h, j, k, l, n, o, p}, det3_1);
    determinante_3x3 det3x3_2 ({e, g, h, i, k, l, m, o, p}, det3_2);
    determinante_3x3 det3x3_3 ({e, f, h, i, j, l, m, n, p}, det3_3);
    determinante_3x3 det3x3_4 ({e, f, g, i, j, k, m, n, o}, det3_4);
    
    always @(*) begin
        det = a * det3_1 - b * det3_2 + c * det3_3 - d * det3_4;
    end
    
endmodule
