`timescale 1ns/1ps
module testbench();

integer handle3;
integer desc3;

logic clk, reset, tx;
logic [7:0] data_in;
logic [31:0] data_out;
logic valid_in, valid_out;

integer i;

// instantiate device to be tested
bus_width_adapter #(.SIZE_IN(8), .SIZE_OUT(32)) dut (
    .clk(clk),
    .reset(reset),
    .valid_in(valid_in),
    .in(data_in),
    .valid_out(valid_out),
    .out(data_out)
);
    
// 1 ns clock
initial begin
    clk = 1'b1;
    forever #1 clk = ~clk;
end

initial begin
    handle3 = $fopen("bwa.out");	
    desc3 = handle3;
end

always begin
    @(posedge clk) begin
        $fdisplay(desc3, "data_in: %h | valid_in: %b | data_out: %h | valid_out: %b", data_in, valid_in, data_out, valid_out);
    end
end


initial begin
    reset = 1'b0;
    #5 reset = 1'b1;
    #5 reset = 1'b0;

    data_in = $urandom();
    valid_in = 1;

    for (i=0; i < 10; i=i+1) begin
        
        @(posedge clk) begin
            data_in = $urandom();
        end
    end

    $finish;
end

endmodule // testbench
