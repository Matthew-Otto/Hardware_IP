`timescale 1ns/1ps
module testbench();

integer handle3;
integer desc3;

logic clk, uclk, reset, rx;
logic [7:0] data;
logic data_val;

logic [71:0] testvector;

integer i;

assign testvector = {1'b1, 10'b1_01101000_0, 10'b1_01100101_0, 10'b1_01101100_0, 10'b1_01101100_0, 10'b1_01101111_0, 10'b1_00001010_0, 10'b1_01010101_0, 1'b1};



// instantiate device to be tested
uart_rx #(.CLK_RATE(10), .BAUD_RATE(1)) dut (
    .clk(clk),
    .areset(reset),
    .rx(rx),
    .data_val(data_val),
    .data(data),
    .ready(1'b1)
);
    
// 1 ns clock
initial begin
    clk = 1'b1;
    forever #1 clk = ~clk;
end

initial begin
    uclk = 1'b1;
    forever #10 uclk = ~uclk;
end


initial begin
    handle3 = $fopen("uart.out");	
    desc3 = handle3;
end

always begin
    @(posedge clk) begin
        $fdisplay(desc3, "uclk: %b | state: %d | rx: %b || val: %b | bit_cnt: %d | data: %b", uclk, dut.state, rx, data_val, dut.bit_cnt, data);
    end
end


initial begin
    reset = 1'b0;
    #5 reset = 1'b1;
    #5 reset = 1'b0;

    for (i=0; i < 71; i=i+1) begin
        
        @(negedge uclk) begin

            rx = testvector[i];
            
        end // @(negedge clk)
    end
end

endmodule // testbench
