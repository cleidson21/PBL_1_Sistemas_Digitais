// Arquivo: determinante_5x5.v
module determinante_5x5 (
    input wire clk,
    input wire reset,
    input wire start,
    input wire signed [7:0] matrix_00, matrix_01, matrix_02, matrix_03, matrix_04,
    input wire signed [7:0] matrix_10, matrix_11, matrix_12, matrix_13, matrix_14,
    input wire signed [7:0] matrix_20, matrix_21, matrix_22, matrix_23, matrix_24,
    input wire signed [7:0] matrix_30, matrix_31, matrix_32, matrix_33, matrix_34,
    input wire signed [7:0] matrix_40, matrix_41, matrix_42, matrix_43, matrix_44,
    output reg signed [39:0] determinant,
    output reg done
);

    // Estados da máquina de estados
    parameter IDLE = 3'b000;
    parameter ELIMINATION = 3'b001;
    parameter MULTIPLY = 3'b010;
    parameter DONE = 3'b011;
    parameter FIND_PIVOT = 3'b100;
    parameter SWAP_ROWS = 3'b101;

    // Registradores para armazenar a matriz durante o processamento
    reg [7:0] mat [0:4][0:4];
    
    // Variáveis para controle do processo
    reg [2:0] state;
    reg [2:0] i;
    reg [2:0] j;
    reg [2:0] k;
    reg [2:0] pivot_row;
    reg [7:0] temp;
    reg [39:0] temp_det;
    reg sign;  // 0 = positivo, 1 = negativo
    
    // Variáveis temporárias para cálculos
    reg [15:0] mult_result;
    reg [15:0] div_result;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            i <= 0;
            j <= 0;
            k <= 0;
            pivot_row <= 0;
            temp_det <= 1;
            sign <= 0;
            done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        // Carrega a matriz para processamento
                        mat[0][0] <= matrix_00; mat[0][1] <= matrix_01; mat[0][2] <= matrix_02; mat[0][3] <= matrix_03; mat[0][4] <= matrix_04;
                        mat[1][0] <= matrix_10; mat[1][1] <= matrix_11; mat[1][2] <= matrix_12; mat[1][3] <= matrix_13; mat[1][4] <= matrix_14;
                        mat[2][0] <= matrix_20; mat[2][1] <= matrix_21; mat[2][2] <= matrix_22; mat[2][3] <= matrix_23; mat[2][4] <= matrix_24;
                        mat[3][0] <= matrix_30; mat[3][1] <= matrix_31; mat[3][2] <= matrix_32; mat[3][3] <= matrix_33; mat[3][4] <= matrix_34;
                        mat[4][0] <= matrix_40; mat[4][1] <= matrix_41; mat[4][2] <= matrix_42; mat[4][3] <= matrix_43; mat[4][4] <= matrix_44;
                        
                        i <= 0;
                        j <= 0;
                        k <= 0;
                        pivot_row <= 0;
                        temp_det <= 1;
                        sign <= 0;
                        done <= 0;
                        state <= ELIMINATION;
                    end
                end
                
                ELIMINATION: begin
                    // Verifica se o pivô atual é zero antes de prosseguir
                    if (i < 4) begin  // Processa até a penúltima linha
                        if (mat[i][i] == 0) begin
                            // Pivô é zero, precisa encontrar um pivô não nulo
                            state <= FIND_PIVOT;
                            j <= i + 1;  // Começar busca na próxima linha
                        end else if (j < 4 - i) begin
                            if (k < 5) begin
                                if (k == 0) begin
                                    j <= j + 1;
                                    k <= 0;
                                end else begin
                                    // Processo de eliminação gaussiana
                                    mult_result <= mat[i+j][i] * mat[i][k];
                                    div_result <= mult_result / mat[i][i];
                                    mat[i+j][k] <= mat[i+j][k] - div_result[7:0];
                                    k <= k + 1;
                                end
                            end else begin
                                j <= j + 1;
                                k <= 0;
                            end
                        end else begin
                            i <= i + 1;
                            j <= 0;
                            k <= 0;
                        end
                    end else begin
                        state <= MULTIPLY;
                        i <= 0;
                    end
                end
                
                FIND_PIVOT: begin
                    // Busca por um elemento não nulo na coluna i, abaixo da linha i
                    if (j < 5) begin
                        if (mat[j][i] != 0) begin
                            // Encontrou um pivô não nulo
                            pivot_row <= j;
                            k <= 0;  // Preparar para troca de linhas
                            state <= SWAP_ROWS;
                        end else begin
                            j <= j + 1;  // Continua procurando
                        end
                    end else begin
                        // Nenhum pivô não nulo encontrado - matriz singular
                        temp_det <= 0;
                        state <= DONE;
                    end
                end
                
                SWAP_ROWS: begin
                    // Troca a linha i com a linha pivot_row
                    if (k < 5) begin
                        temp <= mat[i][k];
                        mat[i][k] <= mat[pivot_row][k];
                        mat[pivot_row][k] <= temp;
                        k <= k + 1;
                    end else begin
                        sign <= !sign;  // Inverte o sinal do determinante
                        j <= 0;
                        k <= 0;
                        state <= ELIMINATION;  // Retorna ao processo de eliminação
                    end
                end
                
                MULTIPLY: begin
                    // Calcula o determinante multiplicando os elementos da diagonal
                    if (i < 5) begin
                        temp_det <= temp_det * mat[i][i];
                        i <= i + 1;
                    end else begin
                        // Aplica o sinal baseado no número de trocas
                        if (sign)
                            determinant <= -temp_det;
                        else
                            determinant <= temp_det;
                        state <= DONE;
                    end
                end
                
                DONE: begin
                    done <= 1;
                    if (!start) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule