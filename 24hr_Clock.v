`timescale 1ns / 1ps

module FPGAClock_24hr(
    input clk, center, right, left, up, down,// board clk and pushbuttons
    output [6:0] seg,//display
    output [3:0] an,//enable displays
    output AMPM_indicator_led,// light to show AM or PM
    output clock_mode_indicator_led // Shows clock mode
    );
    
    reg [31:0] counter = 0;
    parameter max_count = 100_000_000; //1sec
    
    reg [5:0] hrs, min, sec = 0;
    reg [3:0] minute_ones, minute_tens, hour_ones, hour_tens = 0;
    reg toggle = 0;
    
    reg pm = 0;
    assign AMPM_indicator_led = pm;
    reg clock_mode = 0;
    assign clock_mode_indicator_led = clock_mode;

    Seven_Segment_Display(clk, minute_ones, minute_tens, hour_ones, hour_tens, seg, an);

    parameter display_time = 1'b0;
    parameter set_time = 1'b1;
    reg current_mode = set_time;

    always @(posedge clk) begin
        case(current_mode)
            display_time: begin
                if (center) begin
                    clock_mode <= 0;
                    current_mode <= set_time;
                    counter <= 0;
                    toggle <= 0;
                    sec <= 0;
                end

                if (counter < max_count) begin
                    counter <= counter + 1;
                end else begin
                    counter <= 0;
                    sec <= sec + 1;
                end
            end

    set_time: begin
        if (center) begin
            clock_mode <= 1;
            current_mode <= display_time;
        end

        if (counter < (25_000_000)) begin
            counter <= counter + 1;
        end else begin
            counter <= 0;
            case (toggle)
                1'b0: begin
                    if (up) begin
                        min <= min + 1;
                    end
                    if (down) begin
                        if (min > 0) begin
                            min <= min - 1;
                        end else if (hrs > 1) begin
                            hrs <= hrs - 1;
                            min <= 59;
                        end else if (hrs == 1) begin
                            hrs <= 12;
                            min <= 59;
                        end
                    end

                    if (left || right) begin
                        toggle <= 1;
                    end
                end

                1'b1: begin
                    if (up) begin
                        hrs <= hrs + 1;
                    end
                    if (down) begin
                        if (hrs > 1) begin
                            hrs <= hrs - 1;
                        end else if (hrs == 1) begin
                            hrs <= 12;
                        end
                    end
                    if (right || left) begin
                        toggle <= 0;
                    end
                end
            endcase
        end
    end
  endcase
    

    if (sec >= 60) begin
        sec <= 0;
        min <= min +1;
    end
    if (min >= 60) begin
        min <= 0;
        hrs <= hrs + 1;
    end
    if (hrs >= 24) begin
        hrs <= 0;
    end

    else begin
        minute_ones <= min % 10;
        minute_tens <= min / 10;
        if (hrs < 12) begin
            if (hrs == 0) begin
                hour_ones <= 2;
                hour_tens <= 1;
            end else begin
                hour_ones <= hrs % 10;
                hour_tens <= hrs / 10;
            end
            pm <= 0;
            end else begin
            if (hrs == 12) begin
                hour_ones <= 2;
                hour_tens <= 1;
                end else begin
                hour_ones <= (hrs - 12) % 10;
                hour_tens <= (hrs - 12) / 10;
                end
                pm <= 1;      
        end
    end
  end
endmodule
