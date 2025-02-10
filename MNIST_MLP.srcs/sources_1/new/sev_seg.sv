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
