// FIFO depth can only be a power of 2

module fifo #(parameter WIDTH, parameter DEPTH) (
    input clk,
    input reset,

    input  [WIDTH-1:0]       data_in,
    input                    data_in_val,
    output logic             data_in_rdy,

    output logic [WIDTH-1:0] data_out,
    output logic             data_out_val,
    input                    data_out_rdy
);

localparam ADDR_SIZE = $clog2(WIDTH);

logic full, empty;
logic [ADDR_SIZE:0] wr_ptr, rd_ptr;
logic [WIDTH-1:0] buffer [DEPTH-1:0];

assign full = wr_ptr[ADDR_SIZE] != rd_ptr[ADDR_SIZE] && wr_ptr[ADDR_SIZE-1:0] == rd_ptr[ADDR_SIZE-1:0];
assign empty = rd_ptr == wr_ptr;

assign data_in_rdy = ~full;
assign data_out_val = ~empty;

assign data_out = buffer[rd_ptr[ADDR_SIZE-1:0]];


always @(posedge clk) begin
    if (reset) begin
        wr_ptr <= 0;
        rd_ptr <= 0;
    end else begin
        if (data_in_val && data_in_rdy) begin
            buffer[wr_ptr[ADDR_SIZE-1:0]] <= data_in;
            wr_ptr <= wr_ptr + 1;
        end

        if (data_out_val && data_out_rdy) begin
            rd_ptr <= rd_ptr + 1;
        end
    end
end

endmodule  // fifo