module determinante_5x5 (
    input signed [199:0] matriz_5x5, // Matriz 5x5 compactada (25 elementos de 8 bits cada)
    output reg signed [31:0] det // Resultado do determinante
);
    
    wire signed [7:0] a = matriz_5x5[199:192];
    wire signed [7:0] b = matriz_5x5[191:184];
    wire signed [7:0] c = matriz_5x5[183:176];
    wire signed [7:0] d = matriz_5x5[175:168];
    wire signed [7:0] e = matriz_5x5[167:160];
    wire signed [7:0] f = matriz_5x5[159:152];
    wire signed [7:0] g = matriz_5x5[151:144];
    wire signed [7:0] h = matriz_5x5[143:136];
    wire signed [7:0] i = matriz_5x5[135:128];
    wire signed [7:0] j = matriz_5x5[127:120];
    wire signed [7:0] k = matriz_5x5[119:112];
    wire signed [7:0] l = matriz_5x5[111:104];
    wire signed [7:0] m = matriz_5x5[103:96];
    wire signed [7:0] n = matriz_5x5[95:88];
    wire signed [7:0] o = matriz_5x5[87:80];
    wire signed [7:0] p = matriz_5x5[79:72];
    wire signed [7:0] q = matriz_5x5[71:64];
    wire signed [7:0] r = matriz_5x5[63:56];
    wire signed [7:8] s = matriz_5x5[55:48];
    wire signed [7:0] t = matriz_5x5[47:40];
    wire signed [7:0] u = matriz_5x5[39:32];
    wire signed [7:0] v = matriz_5x5[31:24];
    wire signed [7:0] w = matriz_5x5[23:16];
    wire signed [7:0] x = matriz_5x5[15:8];
    wire signed [7:0] y = matriz_5x5[7:0];
    
    wire signed [31:0] det4_1, det4_2, det4_3, det4_4, det4_5;
    
    determinante_4x4 det4x4_1 ({g, h, i, j, l, m, n, o, q, r, s, t, v, w, x, y}, det4_1);
    determinante_4x4 det4x4_2 ({f, h, i, j, k, m, n, o, p, r, s, t, u, w, x, y}, det4_2);
    determinante_4x4 det4x4_3 ({f, g, i, j, k, l, n, o, p, q, s, t, u, v, x, y}, det4_3);
    determinante_4x4 det4x4_4 ({f, g, h, j, k, l, m, o, p, q, r, t, u, v, w, y}, det4_4);
    determinante_4x4 det4x4_5 ({f, g, h, i, k, l, m, n, p, q, r, s, u, v, w, x}, det4_5);
    
    always @(*) begin
        det = a * det4_1 - b * det4_2 + c * det4_3 - d * det4_4 + e * det4_5;
    end
    
endmodule
