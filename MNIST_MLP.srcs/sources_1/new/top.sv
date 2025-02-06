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



    hex_to_seven_seg S0(
        .hex(nibble),
        .seven_seg(sseg)    
    );


  
    // UART Receiver instantiation
    UART uart_rx(
        .clk_i(clk),
        .RX_i(RX_i),
        .data_o(received_data)
    );

    // Toggle logic for nibbles (slowed clock for human-readable switching)
    always @(posedge clk) begin
        counter <= counter + 1;
        if (counter == 0) begin
            toggle <= ~toggle;
        end

        if (toggle) begin
            nibble <= received_data[7:4]; // Display MSB nibble
            an_control <= 8'b11111110;    // Enable one segment (e.g., AN0)
        end else begin
            nibble <= received_data[3:0]; // Display LSB nibble
            an_control <= 8'b11111101;    // Enable another segment (e.g., AN1)
        end
    end

endmodule

module hex_to_seven_seg(
    input [3:0] hex,
    output reg[6:0] seven_seg
    );
    
    always @(hex) 
        case(hex) //gfedcba
            0: seven_seg = 7'b1000000;    
            1: seven_seg = 7'b1111001;  
            2: seven_seg = 7'b0100100;  
            3: seven_seg = 7'b0110000;  
            4: seven_seg = 7'b0011001;  
            5: seven_seg = 7'b0010010;  
            6: seven_seg = 7'b0000010;  
            7: seven_seg = 7'b1111000;  
            8: seven_seg = 7'b0000000;  
            9: seven_seg = 7'b0010000;  
            10: seven_seg = 7'b0001000;  
            11: seven_seg = 7'b1000011;  
            12: seven_seg = 7'b1000110;  
            13: seven_seg = 7'b0100001;  
            14: seven_seg = 7'b0000110;  
            15: seven_seg = 7'b0001110;  
        endcase           
endmodule
