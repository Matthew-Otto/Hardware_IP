`timescale 1ns/1ps
module testbench();

integer handle3;
integer desc3;

logic clk, reset, tx;
logic [7:0] data;
logic data_val;
logic data_ready;

integer i;

// instantiate device to be tested
uart_tx #(.CLK_RATE(10), .BAUD_RATE(1)) dut (
    .clk(clk),
    .areset(reset),
    .data_write_valid(data_val),
    .data_write_ready(data_ready),
    .data_in(data),
    .txd_out(tx)
);
    
// 1 ns clock
initial begin
    clk = 1'b1;
    forever #1 clk = ~clk;
end

initial begin
    handle3 = $fopen("uart.out");	
    desc3 = handle3;
end

always begin
    @(posedge clk) begin
        $fdisplay(desc3, "state: %h | data_reg: %b | shift_reg: %b | tx: %b | bit_cnt: %d", dut.state, dut.data_reg, dut.shift_reg, tx, dut.bit_cnt);
    end // @(posedge clk)
end


initial begin
    reset = 1'b0;
    #5 reset = 1'b1;
    #5 reset = 1'b0;

    data = $urandom();
    data_val = 1;

    for (i=0; i < 2000; i=i+1) begin
        
        @(posedge clk) begin

            if (data_ready)
                data = $urandom();
            
        end
    end

    $finish;
end

endmodule // testbench
