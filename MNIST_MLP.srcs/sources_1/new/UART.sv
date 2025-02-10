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
                BAUD_RATE_DIVISIOR = 100
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

    always@(posedge reset) begin
        state           <= IDLE;
        bit_counter_reg <= 4'b0;
        rx_done_tick    <= 1;
    end

    always @(*) begin 
        case(CURR_S)
            //IDLE STATE
            IDLE_S: begin
                if(RX_i == 0 && tick_counter_reg == 4'd7) begin
                    rx_done_o          <= 0;
                    bit_counter_reg    <= 0;
                    tick_counter_reg   <= 0;
                    uart_data_reg      <= 0;
                    CURR_S <= DATA_S;
                end
                else begin
                    tick_counter_reg <= tick_counter_reg + 1;
                end
            end
            //DATA STATE
            DATA_S: begin
                if(counter == 4'd15) begin
                    CURR_S              <= DATA;
                    data_o              <= {RX_i, data_o[7:1]};
                    bit_counter_reg     <= bit_counter_reg + 1;
                    tick_counter_reg    <= tick_counter_reg + 1;
                    if(bit_counter_reg == 3'd7) begin
                        CURR_S          <= STOP;
                        bit_counter_reg <= 0;
                        rx_done_o       <= 0;
                    end
                end
                else begin
                    tick_counter_reg    <= tick_counter_reg + 1;
                end
            end
            //STOP STATE
            STOP_S: begin
                if(RX_i == 1) begin
                    CURR_S              <= IDLE_S;
                    rx_done_o           <= 1;
                end    
                else begin
                    tick_counter_reg    <= tick_counter_reg + 1;
                end       
            end
            default: CURR_S             <= IDLE_S;
        endcase
    end
endmodule



