// bus width adapter
// takes an input from a narrower bus over multiple cycles and outputs to a wider bus

module bus_width_increase
#(
    parameter SIZE_IN,
    parameter SIZE_OUT,
    parameter LITTLE_ENDIAN = 1  // When true, LSB of output bus is populated first
)(
    input                       clk,
    output logic                input_ready,
    input                       input_valid,
    input        [SIZE_IN-1:0]  data_in,
    input                       output_ready,
    output logic                output_valid,
    output logic [SIZE_OUT-1:0] data_out
);

initial
    assert (SIZE_OUT % SIZE_IN == 0) else $error("SIZE_OUT must be a multiple of SIZE_IN");

localparam BUFF_SIZE = SIZE_OUT / SIZE_IN;
    
logic [$clog2(BUFF_SIZE)-1:0] ptr;  // TODO: check behavior when BUFF_SIZE is not a power of two (does $clog2 round down?)
logic [SIZE_OUT-1:0] input_buffer;
logic [SIZE_IN-1:0] skid_buffer;
logic overflow;

initial begin
    ptr = BUFF_SIZE-1;
    input_ready = 1;
    output_valid = 0;
    overflow = 0;
end

if (LITTLE_ENDIAN)
    assign data_out = overflow ? {input_buffer[SIZE_OUT-1:SIZE_IN],skid_buffer} : input_buffer;
else
    assign data_out = overflow ? {skid_buffer,input_buffer[SIZE_IN*(BUFF_SIZE-1)-1:0]} : input_buffer;

always @(posedge clk) begin
    if (input_ready && input_valid) begin
            if (LITTLE_ENDIAN)
                input_buffer[(BUFF_SIZE-1 - ptr)*SIZE_IN+:SIZE_IN] <= data_in;
            else
                input_buffer[ptr*SIZE_IN+:SIZE_IN] <= data_in;

            if (ptr == 0) begin
                ptr <= BUFF_SIZE-1;
                output_valid <= 1;
            end else begin
                ptr <= ptr - 1;
            end
    end

    if (output_valid) begin
        if (output_ready) begin
            output_valid <= 0;
            overflow <= 0;
            input_ready <= 1;
        end else if (~overflow) begin
            input_ready <= 0;
            overflow <= 1;

            if (LITTLE_ENDIAN)
                skid_buffer <= input_buffer[SIZE_IN-1:0];
            else
                skid_buffer <= input_buffer[(BUFF_SIZE-1)*SIZE_IN+:SIZE_IN];
        end
    end
end


endmodule  // bus_width_adapter