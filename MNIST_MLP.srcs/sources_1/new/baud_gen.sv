`timescale 1ns / 1ps



/*

EQ for calculating baud rate    
    b - baud rate
    f - freq of clk (for us 100MHz ( nexys a7 clk))
    v - divisor to provide to baud rate generator
    v = ( f / (16 * b) ) - 1

    v = 650 for 9600 bps

*/
module baud_rate_generator(
    input clk_i, reset,          // System clock
    input [10:0] divisor,   // Divisor for baud rate
    output reg baud_tick     // Output baud clock
);
    reg [10:0] counter;
    reg [10:0] counter_next;

    always @(posedge clk_i, posedge reset) begin
        if (reset)
            counter <= 0;
        else 
            counter <= counter_next;
    end
    assign counter_next = (counter == divisor) ? 0 : counter + 1;
    assign baud_tick    = (counter == 1);
endmodule
