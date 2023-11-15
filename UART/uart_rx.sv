// autobaud UART RX module

module uart_rx #(CLK_RATE, BAUD_RATE)(
    input clk,
    input areset,
    input rx,
    input ready,

    output logic data_val,
    output logic [7:0] data
);

localparam CLKS_PER_BAUD = int'(CLK_RATE / BAUD_RATE);
localparam HALF_CLKS_PER_BAUD = int'(CLK_RATE / (BAUD_RATE * 2));


logic [3:0] state;

localparam
    IDLE  = 2'b00,
    START = 2'b01,
    DATA  = 2'b10,
    STOP  = 2'b11;

logic [31:0] clk_cnt;
logic [2:0] bit_cnt;

logic [7:0] data_reg;
logic flag;


always @(posedge clk, posedge areset) begin
    if (areset) begin
        data <= 8'bx;
        data_val <= 0;
    end else if (state == STOP && ~flag) begin
        // if data_val, overflow
        flag <= 1;
        data <= data_reg;
        data_val <= 1;
    end else if (state == IDLE) begin
        flag <= 0;
    end else if (data_val && ready) begin
        data_val <= 0;
    end
end


always @(posedge clk, posedge areset) begin
    if (areset) begin
        state <= IDLE;
    end else begin
        case (state)
            IDLE : begin
                clk_cnt <= 1;
                bit_cnt <= 0;
                if (~rx) state <= START;
            end

            START : begin
                if (clk_cnt == CLKS_PER_BAUD) begin
                    clk_cnt <= 1;
                    state <= DATA;
                end else begin
                    clk_cnt <= clk_cnt + 1;
                end
            end

            DATA : begin
                if (clk_cnt == HALF_CLKS_PER_BAUD) begin
                    data_reg[bit_cnt] <= rx;
                    clk_cnt <= clk_cnt + 1;
                end else if (clk_cnt == CLKS_PER_BAUD) begin
                    clk_cnt <= 1;
                    if (bit_cnt == 7)
                        state <= STOP;
                    else 
                        bit_cnt <= bit_cnt + 1;
                end else begin
                    clk_cnt <= clk_cnt + 1;
                end
            end

            STOP : begin
                if (clk_cnt == HALF_CLKS_PER_BAUD) begin
                    state <= IDLE;
                end else begin
                    clk_cnt <= clk_cnt + 1;
                end
            end
        endcase
    end
end



endmodule // uart_rx