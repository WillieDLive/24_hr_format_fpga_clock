`timescale 1ns / 1ps

module Seven_Segment_Display( //Outputs and Inputs
    input clk, //100MHz
    input [3:0] minute_ones, //4-bits to hold up to #9
    input [3:0] minute_tens,
    input [3:0] hour_ones,
    input [3:0] hour_tens,
    output reg [6:0] seg,
    output reg [3:0] an
    );
    
    //
    reg [1:0] digit_display = 0;
    reg [6:0] display [3:0];
    
    reg [18:0] counter = 0;
    parameter max_count = 500_000; //10ms
    wire [3:0] four_bit [3:0];
    
    //Seven Segment values
    assign four_bit[0] = minute_ones;
    assign four_bit[1] = minute_tens;
    assign four_bit[2] = hour_ones;
    assign four_bit[3] = hour_tens;
    
    //slow clock for 10ms refesh rate
    
    always @(posedge clk) begin
        if (counter < max_count) begin
            counter <= counter + 1;
        end else begin
            digit_display <= digit_display + 1;
             counter <= 0;
        end
        
        case(four_bit[digit_display])
            4'b0000 : display[digit_display] <= 7'b1000000;//0
            4'b0001 : display[digit_display] <= 7'b1111001;//1
            4'b0010 : display[digit_display] <= 7'b0100100;//2
            4'b0011 : display[digit_display] <= 7'b0110000;//3
            4'b0100 : display[digit_display] <= 7'b0011001;//4
            4'b0101 : display[digit_display] <= 7'b0010010;//5
            4'b0110 : display[digit_display] <= 7'b0000010;//6
            4'b0111 : display[digit_display] <= 7'b1111000;//7
            4'b1000 : display[digit_display] <= 7'b0000000;//8
            4'b1001 : display[digit_display] <= 7'b0011000;//9
            4'b1010 : display[digit_display] <= 7'b0001000;//10
            4'b1011 : display[digit_display] <= 7'b0000011;//11
            4'b1011 : display[digit_display] <= 7'b1000110;//12
            4'b1011 : display[digit_display] <= 7'b0100001;//13
            4'b1011 : display[digit_display] <= 7'b0000110;//14
            default : display[digit_display] <= 7'b0001110;//F
        endcase

    
        case(digit_display) //cycles display
            0: begin
                an <= 4'b1110;
                seg <= display[0];
            end

            1: begin
                an <= 4'b1101;
                seg <= display[1];
            end

            2: begin
                an <= 4'b1011;
                seg <= display[2];
            end

            3: begin
                an <= 4'b0111;
                seg <= display[3];
            end
        endcase
    end //end of 10ms clock

            
    
endmodule
