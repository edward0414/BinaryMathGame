// User guide
//go1: show question
//go2: enter your answer

module vga_demo (
        CLOCK_50,                       //  On Board 50 MHz
        // Your inputs and outputs here
        KEY,
        SW,
        // The ports below are for the VGA output.  Do not change.
        VGA_CLK,                        //  VGA Clock
        VGA_HS,                         //  VGA H_SYNC
        VGA_VS,                         //  VGA V_SYNC
        VGA_BLANK_N,                        //  VGA BLANK
        VGA_SYNC_N,                     //  VGA SYNC
        VGA_R,                          //  VGA Red[9:0]
        VGA_G,                          //  VGA Green[9:0]
        VGA_B                           //  VGA Blue[9:0]
    );

    input           CLOCK_50;               //  50 MHz
    input   [9:0]   SW;
    input   [3:0]   KEY;

    // Declare your inputs and outputs here
    // Do not change the following outputs
    output          VGA_CLK;                //  VGA Clock
    output          VGA_HS;                 //  VGA H_SYNC
    output          VGA_VS;                 //  VGA V_SYNC
    output          VGA_BLANK_N;                //  VGA BLANK
    output          VGA_SYNC_N;             //  VGA SYNC
    output  [9:0]   VGA_R;                  //  VGA Red[9:0]
    output  [9:0]   VGA_G;                  //  VGA Green[9:0]
    output  [9:0]   VGA_B;                  //  VGA Blue[9:0]
    
    wire reset_n;
    assign reset_n = KEY[0];
    
    // Create the colour, x, y and writeEn wires that are inputs to the controller.
    wire [2:0] colour;
    wire [7:0] x;
    wire [6:0] y;
    wire writeEn;

    wire ld_a, ld_b, ld_c, ld_d, ld_x_out, ld_y_out;
    wire draw, erase, black, finish, ready;

    // Create an Instance of a VGA controller - there can be only one!
    // Define the number of colours as well as the initial background
    // image file (.MIF) for the controller.
    vga_adapter VGA(
            .resetn(reset_n),
            .clock(CLOCK_50),
            .colour(colour),
            .x(x),
            .y(y),
            .plot(writeEn),
            /* Signals for the DAC to drive the monitor. */
            .VGA_R(VGA_R),
            .VGA_G(VGA_G),
            .VGA_B(VGA_B),
            .VGA_HS(VGA_HS),
            .VGA_VS(VGA_VS),
            .VGA_BLANK(VGA_BLANK_N),
            .VGA_SYNC(VGA_SYNC_N),
            .VGA_CLK(VGA_CLK));
        defparam VGA.RESOLUTION = "160x120";
        defparam VGA.MONOCHROME = "FALSE";
        defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
        defparam VGA.BACKGROUND_IMAGE = "black.mif";
            
    // Put your code here. Your code should produce signals x,y,colour and writeEn/plot
    // for the VGA controller, in addition to any other functionality your design may require.
    
        // Instansiate datapath
    datapath d0(
        .x_in(SW[6:0]),
        .y_in(SW[6:0]),
        .reset_n(reset_n),
        .ld_a(ld_a),
        .ld_b(ld_b),
        .ld_c(ld_c),
        .ld_d(ld_d),
        .ld_x_out(ld_x_out),
        .ld_y_out(ld_y_out),
        .draw(draw),
        .finish(finish),
        .erase(erase),  
        .black(black),
        .colour_in(SW[9:7]),
        .colour_out(colour),
        .clock(CLOCK_50),
        .ready(ready),
        .x_out(x),
        .y_out(y)
    );

        // Instansiate FSM control
        control c0(
        .go1(~KEY[3]),
        .go2(~KEY[1]),
        .finish(finish),
        .black(black),
        .reset_n(reset_n),
        .clock(CLOCK_50),
        .ld_a(ld_a),
        .ld_b(ld_b),
        .ld_c(ld_c),
        .ld_d(ld_d),
        .ld_x_out(ld_x_out),
        .ld_y_out(ld_y_out),
        .draw(draw),
        .erase(erase),  
        .ready(ready),
        .plot(writeEn)
    );
    
endmodule

module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;  
            default: segments = 7'h7f;
        endcase
endmodule


module control(clk, resetn, show_q, go1, go2, ld_ans, erase);

    input clk;
    input resetn;
    input go1;
    input go2;

    output reg  ld_ans; 
    //output reg rip_time;
    //output reg erase; 
    output reg show_q;


	localparam 	BLANK = 4'b0000;
                DISPLAY = 4'b0001;
				LOAD_NUM_WAIT = 4'b0002;
				RIP = 4'b0003;


	always @(*)
	begin: state_table
		case (current_state)
            BLANK: next_state = go1 ? DISPLAY : BLANK;
			DISPLAY: next_state = go2 ? LOAD_NUM_WAIT : DISPLAY;
			LOAD_NUM_WAIT: next_state = go2 ? RIP : LOAD_NUM_WAIT;
			RIP: next_state = BLANK;
		default: next_state = BLANK;
		endcase
	end


    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_ans = 1'b0;
        show_q = 1'b0;

        case (current_state)
            BLANK: begin
                show_q = 1'b1;
                end
            DISPLAY: begin
                ld_ans = 1'b1;
                end
            RIP: begin
                //rip_time = 1'b1;
                //erase = 1'b1;
                //set cur_score if right
                //set rip_counter to nanosec if right, 120 sec if wrong
            end

        endcase
    end

        // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= DISPLAY;
        else
            current_state <= next_state;
    end // state_FFS
endmodule
   

module datapath(
    input clk,
    input resetn,
    input [7:0] data_in,
    input ld_ans,
    input show_q,
    input alu_op, 
    input correct,
    input better,
    output reg [7:0] data_result,
    output reg [2:0] score,
    output reg [2:0] high_score,
    output reg [1:0] time
    );
    
    // input registers
    reg [7:0] in, q1, q2, temp_q1, temp_q2;

    // time, scoreboard
    reg [1:0] time;
    reg [2:0] score, high_score;

    // alu_op
    reg [1:0] alu_op, temp_op;

    // output of the alu
    reg [7:0] alu_out;


    //Random number generator (Q1)

    //Random number generator (Q2)

    //Random number generator (ALU_OP)


    // Registers in, q1, q2, alu_op with respective input logic
    always @ (posedge clk) begin
        if (!resetn) begin
            in <= 8'b0; 
            q1 <= 8'b0; 
            q2 <= 8'b0;  
        end
        else begin
            if (ld_ans)
                in <= data_in;
                q1 <= temp_q1;
                q2 <= temp_q2;
                alu_op <= temp_op;
        end
    end
 

     // The ALU 
    always @(*)
    begin : ALU
        // alu
        case (alu_op)
            2'b00: begin
                   alu_out = q1 + q2; //performs addition
                end
            2'b01: begin
                   alu_out = q1 * q2; //performs multiplication
                end
            2'b11: begin
                   alu_out = q1 - q2; //performs subtraction
                end
            default: alu_out = 8'b0;
        endcase
    end

 
    //Result comparator
    assign correct = (alu_out == in)? 1:0;

    //High score comparator
    assign better = (score > high_score)? 1:0;


    //Score_counter
    always @ (posedge clk) begin
        if (!reset) begin
            score <= 3'd0;
            end
        else begin
            if (correct)
            score <= score + 3'd1;
            if (better)
            high_score <= score;
        end
    end


    //Time_counter
    always @ (posedge clk) begin
        if (!reset) begin
            time <= 2'd30;
            end
        else if (ld_ans) begin
            time <= time - 2'd1;
            //rip_act <= (time == 2'd0)? 1:0;
        end
    end


    // x reset counter, different case for different number
    always @(posedge clock)
    begin   
        if (!reset_n)
            reset_counter1 <= 8'd159; 
        else if (erase) begin
            if (reset_counter1 == 8'd0)
                reset_counter1 <= 8'd159;
            else
                reset_counter1 <= reset_counter1 - 1'b1;
        end
    end


    // y reset counter, different case for different number
    always @(posedge clock)
    begin   
        if (!reset_n)
            reset_counter2 <= 7'd119;
        else if (reset_counter1 == 8'd0)
            reset_counter2 <= reset_counter2 - 1'b1;
    end


    // draw counter, could be the same for every number?
    always @(posedge clock)
    begin
        if (draw) 
            draw_counter <=  draw_counter + 1'b1;
        else if (ready)
            draw_counter = 4'b1111;
        else if (!reset_n)
            draw_counter <= 4'b0000;
    end


    //RIP_activation

    //RIP_counter


    //

    assign x_out = erase ? reset_counter1: alu_x_out;
    assign y_out = erase ? reset_counter2: alu_y_out;
    assign colour_out = erase ? 3'b000: colour_in;
    assign black = !reset_counter1 & !reset_counter2;
    assign finish = draw_counter[0] & draw_counter[1] & draw_counter[2] & draw_counter[3];
    
endmodule


