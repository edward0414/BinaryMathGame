// User guide
//go: load q1 and q2  KEY[3]
//go1: show question  KEY[2]
//go2: enter your answer  KEY[1]
//resetn               KEY[0]
//data_in              SW[7-0]

module math(
        CLOCK_50,                       //  On Board 50 MHz
        // Your inputs and outputs here
        KEY,
        SW,
        // The ports below are for the VGA output.  Do not change.
        //VGA_CLK,                        //  VGA Clock
        //VGA_HS,                         //  VGA H_SYNC
        //VGA_VS,                         //  VGA V_SYNC
        //VGA_BLANK_N,                        //  VGA BLANK
        //VGA_SYNC_N,                     //  VGA SYNC
        //VGA_R,                          //  VGA Red[9:0]
        //VGA_G,                          //  VGA Green[9:0]
        //VGA_B,                           //  VGA Blue[9:0]
        HEX0,
        HEX1,
        HEX2,
        HEX3,
        HEX4,
        HEX5
    );

    input   CLOCK_50;               //  50 MHz
    input   [9:0] SW;
    input   [3:0] KEY;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    
    wire resetn;
    assign resetn = KEY[0];
    wire clk;
    assign clk = CLOCK_50;

    /*
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
    */
    
    /*
    // Create the colour, x, y and writeEn wires that are inputs to the controller.
    wire [2:0] colour;
    wire [7:0] x;
    wire [6:0] y;
    wire writeEn;
    */


    /*
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
				 //Signals for the DAC to drive the monitor.
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
    */
      

    // Put your code here. Your code should produce signals x,y,colour and writeEn/plot
    // for the VGA controller, in addition to any other functionality your design may require.
    
    wire [7:0] score;
    wire [7:0] time1;
    wire [7:0] high_score;
    wire show_q, ld_q1, ld_q2, ld_ans;
   
	 

    
    // Instansiate datapath and control
    datapath d0(
        .clk(clk),
        .resetn(resetn),
        .data_in(SW[7:0]),
        .ld_ans(ld_ans),
        .ld_q1(ld_q1),
        .ld_q2(ld_q2),
        .show_q(show_q),
        .score(score),
        .high_score(high_score),
        .time1(time1)
    );	 
	 
	 
    control c0(
        .clk(clk), 
        .resetn(resetn), 
        .show_q(show_q), 
        .go(~KEY[3]), 
        .go1(~KEY[2]), 
        .go2(~KEY[1]), 
        .ld_q1(ld_q1), 
        .ld_q2(ld_q2), 
        .ld_ans(ld_ans)
        );

    hex_decoder H0(
        .hex_digit(score[3:0]), 
        .segments(HEX0)
        );
        
    hex_decoder H1(
        .hex_digit(score[7:4]), 
        .segments(HEX1)
        );

    hex_decoder H2(
        .hex_digit(time1[3:0]), 
        .segments(HEX2)
        );
        
    hex_decoder H3(
        .hex_digit(time1[7:4]), 
        .segments(HEX3)
        );

    hex_decoder H4(
        .hex_digit(high_score[3:0]), 
        .segments(HEX4)
        );
        
    hex_decoder H5(
        .hex_digit(high_score[7:4]), 
        .segments(HEX5)
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
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule

module control(clk, resetn, show_q, go, go1, go2, ld_q1, ld_q2, ld_ans);

    input clk;
    input resetn;
    input go;
    input go1;
    input go2;


    output reg ld_q1;
    output reg ld_q2;
    output reg  ld_ans; 
    //output reg rip_time;
    //output reg erase; 
    output reg show_q;

	reg [3:0] current_state, next_state;
	
	localparam 	Q1_GEN = 4'd0,
                Q2_GEN = 4'd1,
                DISPLAY= 4'd2,
                LOAD_NUM = 4'd3,
				LOAD_NUM_WAIT = 4'd4,
				RIP = 4'd5;


	always @(*)
	begin: state_table
		case (current_state)
            Q1_GEN: next_state = go ? Q1_GEN : Q2_GEN;
            Q2_GEN: next_state = go ? Q2_GEN : DISPLAY;
            DISPLAY: next_state = go1 ? LOAD_NUM : DISPLAY;
			LOAD_NUM: next_state = go2 ? LOAD_NUM_WAIT : LOAD_NUM;
			LOAD_NUM_WAIT: next_state = go2 ? LOAD_NUM_WAIT : RIP;
			RIP: next_state = Q1_GEN;
		default: next_state = Q1_GEN;
		endcase
	end


    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_q1 = 1'b0;
        ld_q2 = 1'b0;
        ld_ans = 1'b0;
        show_q = 1'b0;

        case (current_state)
            Q1_GEN: begin
                ld_q1 = 1'b1;
                end
            Q2_GEN: begin
                ld_q2 = 1'b1;
                end
            DISPLAY: begin
                show_q = 1'b1;
                end
            LOAD_NUM: begin
                ld_ans = 1'b1;
                end
            //RIP: begin
                //rip_time = 1'b1;
                //erase = 1'b1;
                //set cur_score if right
                //set rip_counter to nanosec if right, 120 sec if wrong
            //end

        endcase
    end

        // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= Q1_GEN;
        else
            current_state <= next_state;
    end // state_FFS
endmodule
   

module datapath( clk, resetn, data_in, ld_ans, ld_q1, ld_q2, show_q, score, high_score, time1);

    input clk;
    input resetn;
    input [7:0] data_in;
    input ld_ans;
    input ld_q1;
    input ld_q2;
    input show_q;
    output reg [7:0] score = 0;
    output reg [7:0] high_score = 0;
    output reg [7:0] time1 = 30;
    
	 
	 
    // wire
    wire better, correct;
	
    // input registers
    reg [7:0] in, q1, q2; 
    reg [7:0] temp_q1 = 255;
    reg [7:0] temp_q2 = 255;

    // time, scoreboard
    reg [27:0] counter;

    // alu_op
    reg [1:0] alu_op; 
    reg [1:0] temp_op = 3;

    // output of the alu
    reg [7:0] alu_out;


    //Random number generator (Q1)
    wire feedback = temp_q1[7];

    always @(posedge clk)
    begin
      temp_q1[0] <= feedback;
      temp_q1[1] <= temp_q1[0];
      temp_q1[2] <= temp_q1[1] ^ feedback;
      temp_q1[3] <= temp_q1[2] ^ feedback;
      temp_q1[4] <= temp_q1[3] ^ feedback;
      temp_q1[5] <= temp_q1[4];
      temp_q1[6] <= temp_q1[5];
      temp_q1[7] <= temp_q1[6];
    end

    always @ (posedge clk) begin
        if (!resetn) begin
            q1 <= 8'b0;
        end
        else begin
            if (ld_q1)
                q1 <= temp_q1;
        end
    end


    //Random number generator (Q2)
    wire feedback2 = temp_q2[7];

    always @(posedge clk)
    begin
      temp_q2[0] <= feedback2;
      temp_q2[1] <= temp_q2[0];
      temp_q2[2] <= temp_q2[1] ^ feedback2;
      temp_q2[3] <= temp_q2[2] ^ feedback2;
      temp_q2[4] <= temp_q2[3] ^ feedback2;
      temp_q2[5] <= temp_q2[4];
      temp_q2[6] <= temp_q2[5];
      temp_q2[7] <= temp_q2[6];
    end

    always @ (posedge clk) begin
        if (!resetn) begin
            q2 <= 8'b0;
        end
        else begin
            if (ld_q2)
                q2 <= temp_q2;
        end
    end



    //Random number generator (ALU_OP)
    always @(posedge clk)
    begin
      temp_op[0] <= temp_op[1];
      temp_op[1] <= temp_op[0] ^ temp_op[1];
    end


    // Registers in, q1, q2, alu_op with respective input logic
    always @ (posedge clk) begin
        if (!resetn) begin
            in <= 8'b0;
        end
        else begin
            if (ld_ans)
                in <= data_in;
                alu_op <= temp_op;
        end
    end
 

     // The ALU 
    always @(*)
    begin : ALU
        // alu
        case (alu_op)
            2'b10: begin
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
        if (!resetn) begin
            score <= 8'b0;
            end
        else begin
            if (correct)
            score <= score + 1'b1;
            if (better)
            high_score <= score;
        end
    end


    //Time_counter
    always @(posedge clk)
    begin
        if (resetn == 1'b0)
			begin
				time1 <= 8'b0001_1110;
				counter <= 1'd0;
			end
		  else if (show_q) begin
			  if (counter == 27'b0) begin
					 counter <= 49_999_999;
					 time1 <= time1 - 1'b1;
					 end
			  else
					begin
					counter <= counter - 1'b1;
					end
			end
	end
	
	//assign rip_act = (time1 == 8'b0)? 1 : 0;

    /*
    // x reset counter, different case for different number
    always @(posedge clk)
    begin   
        if (!resetn)
            reset_counter1 <= 8'd159; 
        else if (erase) begin
            if (reset_counter1 == 8'd0)
                reset_counter1 <= 8'd159;
            else
                reset_counter1 <= reset_counter1 - 1'b1;
        end
    end
    */


    /*
    // y reset counter, different case for different number
    always @(posedge clk)
    begin   
        if (!resetn)
            reset_counter2 <= 7'd119;
        else if (reset_counter1 == 8'd0)
            reset_counter2 <= reset_counter2 - 1'b1;
    end
    */

    /*
    // draw counter, could be the same for every number?
    always @(posedge clk)
    begin
        if (draw) 
            draw_counter <=  draw_counter + 1'b1;
        else if (ready)
            draw_counter = 4'b1111;
        else if (!reset_n)
            draw_counter <= 4'b0000;
    end
    */

    /*
    //RIP_activation

    //RIP_counter


    //

    assign x_out = erase ? reset_counter1: alu_x_out;
    assign y_out = erase ? reset_counter2: alu_y_out;
    assign colour_out = erase ? 3'b000: colour_in;
    assign black = !reset_counter1 & !reset_counter2;
    assign finish = draw_counter[0] & draw_counter[1] & draw_counter[2] & draw_counter[3];
    */
    
endmodule


