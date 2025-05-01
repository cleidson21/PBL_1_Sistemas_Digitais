

module uart_receiver (
    input clk,
    input receiver,

    output reg [199:0] data_for_memory_ = 0,
    output reg write_in_memory = 0
);

    localparam CLK_FREQ = 50_000_000;
    localparam BAUD_RATE = 9600;
    localparam BIT_TICKS = CLK_FREQ / BAUD_RATE;  // ≈ 5208
    localparam HALF_BIT_TICKS = BIT_TICKS / 2;

    reg [12:0] tick_counter = 0;
    reg [3:0] bit_index = 0;
    reg [7:0] data_byte = 0;
    reg receiving = 0;
    reg [2:0] state = 0;

    localparam IDLE = 0;
    localparam START_BIT = 1;
    localparam DATA_BITS = 2;
    localparam STOP_BIT = 3;

    always @(posedge clk) begin
        case (state)
            IDLE: begin
                write_in_memory <= 0;
                if (receiver == 0) begin  // Start bit detectado (nível baixo)
                    state <= START_BIT;
                    tick_counter <= 0;
                    bit_index <= 0;
                end
            end

            START_BIT: begin
                tick_counter <= tick_counter + 1;
                if (tick_counter == HALF_BIT_TICKS) begin
                    tick_counter <= 0;
                    state <= DATA_BITS;
                end
            end

            DATA_BITS: begin
                tick_counter <= tick_counter + 1;
                if (tick_counter == BIT_TICKS) begin
                    tick_counter <= 0;
                    data_byte[bit_index] <= receiver;
                    bit_index <= bit_index + 1;

                    if (bit_index == 7) begin
                        state <= STOP_BIT;
                    end
                end
            end

				STOP_BIT: begin
					 tick_counter <= tick_counter + 1;
					 if (tick_counter == BIT_TICKS) begin
						  tick_counter <= 0;

						  if (receiver == 1) begin
								data_for_memory_ <= {data_for_memory_[191:0], data_byte};
								write_in_memory <= 1;
						  end
						  state <= IDLE;
					 end
				end
        endcase
    end
endmodule
