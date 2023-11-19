// bus width decrease
// takes an input from a wider bus and outputs to a narrower bus over multiple cycles

module bus_width_decrease
#(
    parameter SIZE_IN,
    parameter SIZE_OUT,
    // TODO: find a more descriptive name
    parameter LITTLE_ENDIAN = 1  // When true, LSB of output bus is populated first
)(
    input                 clk,
    output logic          input_ready,
    input                 input_valid,
    input  [SIZE_IN-1:0]  data_in,
    input                 output_ready,
    output logic          output_valid,
    output logic [SIZE_OUT-1:0] data_out
);

initial
    assert (SIZE_IN % SIZE_OUT == 0) else $error("SIZE_IN must be a multiple of SIZE_OUT");

localparam BUFF_SIZE = SIZE_IN / SIZE_OUT;

logic [$clog2(BUFF_SIZE)-1:0] ptr;  // TODO: check behavior when BUFF_SIZE is not a power of two (does $clog2 round down?)
logic [SIZE_IN-1:0] input_buffer;
logic [SIZE_OUT-1:0] skid_buffer;
logic overflow;

initial begin
    input_ready = 1;
end


if (LITTLE_ENDIAN)
    assign data_out = overflow ? skid_buffer : input_buffer[(BUFF_SIZE-1 - ptr)*SIZE_OUT+:SIZE_OUT];
else
    assign data_out = overflow ? skid_buffer : input_buffer[ptr*SIZE_OUT+:SIZE_OUT];

always @(posedge clk) begin
    if (input_ready) begin  // internal buffer is empty
        if (input_valid) begin  // load input to internal buffer
            input_buffer <= data_in;
            output_valid <= 1;
            ptr <= BUFF_SIZE-1;
            input_ready <= 0;
            
            if (~output_ready) begin // overflow
                overflow <= 1;
                skid_buffer <= LITTLE_ENDIAN ? input_buffer[(BUFF_SIZE-1)*SIZE_OUT+:SIZE_OUT] : input_buffer[SIZE_OUT-1:0];
            end
        end else begin  // stall, output invalid once ptr 0 is consumed
            if (output_ready)
                output_valid <= 0;
        end
    end else if (output_ready) begin
        if (overflow) begin
            overflow <= 0;
        end else if (ptr == 1) begin
            input_ready <= 1;
            ptr <= ptr - 1;
        end else if (ptr != 0) begin
            ptr <= ptr - 1;
        end
    end
end


endmodule  // bus_width_decrease