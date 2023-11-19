// bus width adapter
// takes an input from a narrower bus over multiple cycles and outputs to a wider bus

module bus_width_increase
#(
    parameter SIZE_IN,
    parameter SIZE_OUT,
    // TODO: find a more descriptive name
    parameter LITTLE_ENDIAN = 1  // When true, LSB of output bus is populated first
)(
    input                 clk,
    input                 valid_in,
    input  [SIZE_IN-1:0]  data_in,
    output logic          valid_out,
    output logic [SIZE_OUT-1:0] data_out
);

localparam BUFF_SIZE = SIZE_OUT / SIZE_IN;

initial
    assert (SIZE_OUT % SIZE_IN == 0) else $error("SIZE_OUT must be a multiple of SIZE_IN");

logic [$clog2(BUFF_SIZE)-1:0] ptr;  // TODO: check behavior when BUFF_SIZE is not a power of two (does $clog2 round down?)

initial begin
    ptr = BUFF_SIZE-1;
end

always @(posedge clk) begin
    if (valid_in) begin
        if (LITTLE_ENDIAN)
            data_out[(BUFF_SIZE-1 - ptr)*SIZE_IN+:SIZE_IN] <= data_in;
        else
            data_out[ptr*SIZE_IN+:SIZE_IN] <= data_in;

        if (ptr == 0) begin
            ptr <= BUFF_SIZE-1;
            valid_out <= 1;
        end else begin
            ptr <= ptr - 1;
            valid_out <= 0;
        end
    end
end


endmodule  // bus_width_adapter