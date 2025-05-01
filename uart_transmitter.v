

module uart_transmitter (
    input wire clk,
    input wire transmit,
    input wire [7:0] data,
    output reg tx = 1,  // Linha inativa é alta
    output reg busy = 0
);

    localparam CLK_FREQ = 50_000_000;
    localparam BAUD_RATE = 9600;
    localparam BIT_TICKS = CLK_FREQ / BAUD_RATE;  // ≈ 5208

    reg [12:0] tick_counter = 0;
    reg [3:0] bit_index = 0;
    reg [9:0] shift_reg = 10'b1111111111; // start + 8 data + stop

    reg [1:0] state = 0;
    localparam IDLE = 0, START = 1, SEND = 2;

    always @(posedge clk) begin
        case (state)
            IDLE: begin
                tx <= 1;
                tick_counter <= 0;
                bit_index <= 0;
                busy <= 0;

                if (transmit) begin
                    // Preparar shift_reg com start bit, data, stop bit
                    shift_reg <= {1'b1, data, 1'b0};
                    state <= SEND;
                    busy <= 1;
                end
            end

            SEND: begin
                tick_counter <= tick_counter + 1;

                if (tick_counter == BIT_TICKS) begin
                    tick_counter <= 0;
                    tx <= shift_reg[0];
                    shift_reg <= {1'b1, shift_reg[9:1]};  // deslocar direita
                    bit_index <= bit_index + 1;

                    if (bit_index == 9) begin
                        state <= IDLE;
                    end
                end
            end
        endcase
    end
endmodule