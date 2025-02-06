`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/19/2025 09:35:28 PM
// Design Name: 
// Module Name: UART
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


 module UART
    #(parameter DATA_BITS = 8,
                STOP_BIT_TICK = 16
    )
    (
    input             clk_i,
    input         reset_n_i,
    input              RX_i,
    input      state_tick_i,
    output reg [7:0] data_o,
    output reg    rx_done_o
    );

    reg [1:0]           CURR_S;
    parameter   IDLE_S = 2'b00;
    parameter  START_S = 2'b01;
    parameter   DATA_S = 2'b10;
    parameter   STOP_S = 2'b11;

    reg [$clog2(DATA_BITS) - 1:0] bit_counter_reg;   // Keeps track of number of bits recieved
    reg [DATA_BITS - 1:0]           uart_data_reg;
    reg [3:0]                    tick_counter_reg;       // For timing within states

    
    always @(*) begin 
        case(CURR_S)

            IDLE_S: begin

                
                if(RX_i == 0) begin
                    CURR_S <= START_S;
                end
            end
            START_S: begin
                if(RX_i == 0) begin
                    CURR_S <= DATA_S;
                    bit_counter_reg <= 0;
                end
            end
            DATA_S: begin
                CURR_S <= DATA_S;
                uart_data[bit_counter_reg] <= RX_i;
                bit_counter_reg <= bit_counter_reg + 1;  
            end
            STOP_S: begin
                if(RX_i == 1) begin
                    CURR_S <= IDLE_S;
                    bit_counter_reg <= 0;
                end           
            end
            default: CURR_S = IDLE_S;
        endcase
    end
endmodule


module baud_rate_generator(
    input clk_i,            // System clock
    input [15:0] divisor,   // Divisor for baud rate
    output reg baud_clk     // Output baud clock
);
    reg [15:0] counter;

    always @(posedge clk_i) begin
        if (counter == divisor) begin
            counter <= 0;
            baud_clk <= ~baud_clk; // Toggle baud clock
        end else begin
            counter <= counter + 1;
        end
    end
endmodule


