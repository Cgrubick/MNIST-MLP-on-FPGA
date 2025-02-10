`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/19/2025 09:33:46 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
    input clk,          // System clock
    input RX_i,           // UART receive input
    input rst,
    output DP,            // Decimal point output
    output [7:0] AN,      // Anode control for seven segments
    output [6:0] sseg     // Seven-segment output 
    );



    assign AN = 1;
    assign DP = 0;

    wire [7:0] received_data; // Byte received from UART
    reg [3:0] nibble;         // Current nibble to display
    reg [7:0] an_control;     // Control for active seven-segment display
    reg toggle;               // Toggles between the two nibbles
    reg [15:0] counter;       // Slow down clock for toggling
    reg baud_ticks;
    wire reciever_done;


    hex_to_seven_seg S0(
        .hex(nibble),
        .seven_seg(sseg)    
    );

    baud_rate_generator baud_rate(
        .clk_i(clk_i),
        .divisor(BAUD_RATE_DIVISIOR),
        .baud_clk(baud_ticks)
    );
  
    // UART Receiver instantiation
    UART uart_rx(
        .clk_i(clk),
        .RX_i(RX_i),
        .reset_n_i(rst),
        .state_tick_i(baud_ticks),
        .rx_done_o(reciever_done),
        .data_o(received_data)
    );


endmodule

