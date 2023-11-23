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

localparam ADDR_SIZE = $clog2(DEPTH);

logic full, empty;
logic wr_ptr_of, rd_ptr_of;
logic [ADDR_SIZE-1:0] wr_ptr, rd_ptr;
logic [WIDTH-1:0] buffer [DEPTH-1:0];

assign full = wr_ptr_of != rd_ptr_of && rd_ptr == wr_ptr;
assign empty = {wr_ptr_of,wr_ptr} == {rd_ptr_of,rd_ptr};

assign data_in_rdy = ~full;
assign data_out_val = ~empty;

assign data_out = buffer[rd_ptr[ADDR_SIZE-1:0]];


always @(posedge clk) begin
    if (reset) begin
        wr_ptr <= 0;
        wr_ptr_of <= 0;
        rd_ptr <= 0;
        rd_ptr_of <= 0;
    end else begin
        if (data_in_val && data_in_rdy) begin
            buffer[wr_ptr[ADDR_SIZE-1:0]] <= data_in;

            if (wr_ptr == DEPTH-1) begin
                wr_ptr <= 0;
                wr_ptr_of <= ~wr_ptr_of;
            end else
                wr_ptr <= wr_ptr + 1;
        end

        if (data_out_val && data_out_rdy) begin
            if (rd_ptr == DEPTH-1) begin
                rd_ptr <= 0;
                rd_ptr_of <= ~rd_ptr_of;
            end else
                rd_ptr <= rd_ptr + 1;
        end
    end
end

endmodule  // fifo