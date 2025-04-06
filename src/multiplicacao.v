module multiplicacao (
    input wire clk,
    input wire start,
    input wire [199:0] matriz_a,
    input wire [199:0] matriz_b,
    output reg [199:0] matriz_result,
    output reg done,
    output reg overflow_global
);
    // Definições internas
    reg signed [7:0] A [0:4][0:4];
    reg signed [7:0] B [0:4][0:4];
    reg signed [15:0] acumulador;
    reg [4:0] i, j, k;
    reg [2:0] estado;

    reg signed [15:0] result [0:4][0:4];
    reg overflow [0:4][0:4];

    localparam IDLE = 3'd0,
               LOAD = 3'd1,
               MULTIPLY = 3'd2,
               STORE = 3'd3,
               DONE = 3'd4;

    // Desempacotar matrizes (sequencialmente no estado LOAD)
    integer x, y;
    always @(posedge clk) begin
        if (estado == LOAD) begin
            for (x = 0; x < 5; x = x + 1) begin
                for (y = 0; y < 5; y = y + 1) begin
                    A[x][y] <= matriz_a[(x*5 + y)*8 +: 8];
                    B[x][y] <= matriz_b[(x*5 + y)*8 +: 8];
                end
            end
        end
    end

    // FSM principal
    always @(posedge clk) begin
        case (estado)
            IDLE: begin
                done <= 0;
                if (start) begin
                    i <= 0;
                    j <= 0;
                    k <= 0;
                    acumulador <= 0;
                    estado <= LOAD;
                end
            end

            LOAD: begin
                estado <= MULTIPLY;
            end

            MULTIPLY: begin
                acumulador <= acumulador + A[i][k] * B[k][j];
                if (k == 4) begin
                    result[i][j] <= acumulador + A[i][k] * B[k][j];
                    overflow[i][j] <= (acumulador > 127 || acumulador < -128);
                    acumulador <= 0;
                    if (j == 4) begin
                        if (i == 4) estado <= STORE;
                        else begin
                            i <= i + 1;
                            j <= 0;
                            k <= 0;
                        end
                    end else begin
                        j <= j + 1;
                        k <= 0;
                    end
                end else begin
                    k <= k + 1;
                end
            end

            STORE: begin
                for (x = 0; x < 5; x = x + 1) begin
                    for (y = 0; y < 5; y = y + 1) begin
                        matriz_result[(x*5 + y)*8 +: 8] <= result[x][y][7:0];
                    end
                end
                overflow_global <= 0;
                for (x = 0; x < 5; x = x + 1) begin
                    for (y = 0; y < 5; y = y + 1) begin
                        if (overflow[x][y]) overflow_global <= 1;
                    end
                end
                estado <= DONE;
            end

            DONE: begin
                done <= 1;
                estado <= IDLE;
            end
        endcase
    end

endmodule
