// bus width adapter
// takes an input from a narrower bus over multiple cycles and outputs to a wider bus

module bus_width_adapter
#(
    parameter SIZE_IN,
    parameter SIZE_OUT,
    // TODO: find a more descriptive name
    parameter BIG_ENDIAN = 1  // When true, MSB of output bus is populated first
    // TODO: parameterize size up or size down in same module
)(
    input                 clk,
    input                 reset,
    input                 valid_in,
    input  [SIZE_IN-1:0]  in,
    output logic          valid_out,
    output logic [SIZE_OUT-1:0] out
);

initial
    assert (SIZE_OUT % SIZE_IN == 0);  // new bus size must be a multiple of input bus


localparam BUFF_SIZE = SIZE_OUT / SIZE_IN;

logic [$clog2(BUFF_SIZE)-1:0] ptr;  // TODO: check behavior when BUFF_SIZE is not a power of two (does $clog2 round down?)

always @(posedge clk) begin
    if (reset) begin
        ptr <= BUFF_SIZE-1;
    end else if (valid_in) begin
        if (BIG_ENDIAN)
            out[ptr*SIZE_IN+:SIZE_IN] <= in;
        else
            out[(BUFF_SIZE-1 - ptr)*SIZE_IN+:SIZE_IN] <= in;

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