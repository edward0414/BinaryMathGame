// User guide
//go: load q1 and q2  KEY[3]
//go1: show question  KEY[2]
//go2: enter your answer  KEY[1]
//resetn               KEY[0]
//data_in              SW[7-0]
//Enter your answer when the question shows up. If correct, screen turns black and you get one point. Restart.
//If not correct, the screen turns RIP. You have to manually reset.
//Also, if no correct answer is entered before the countdown ends, the screen turns RIP as well.

module math(
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
        VGA_B,                           //  VGA Blue[9:0]
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
    

    // Create the colour, x, y and writeEn wires that are inputs to the controller.
    wire [2:0] colour;
    wire [7:0] x;
    wire [6:0] y;
    wire writeEn;


    
    // Create an Instance of a VGA controller - there can be only one!
    // Define the number of colours as well as the initial background
    // image file (.MIF) for the controller.
    vga_adapter VGA(
            .resetn(resetn),
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
    
      

    // Put your code here. Your code should produce signals x,y,colour and writeEn/plot
    // for the VGA controller, in addition to any other functionality your design may require.
    
    wire [7:0] score;
    wire [7:0] timer;
    wire [7:0] high_score;
    wire show_q, ld_q1, ld_q2, ld_ans, erase, operator, rip_draw, q_finish, o_finish, black, rip_act;
   
	 

    
    // Instansiate datapath and control	 
    control c0(
        .clk(clk), 
        .resetn(resetn), 
        .go(~KEY[3]), 
        .go1(~KEY[2]), 
        .go2(~KEY[1]),
        .correct(correct),
        .black(black),
        .rip_act(rip_act),
        .q_finish(q_finish),
        .o_finish(o_finish), 
        .ld_q1(ld_q1), 
        .ld_q2(ld_q2), 
        .ld_ans(ld_ans),
        .erase(erase),
        .show_q(show_q),
        .rip_draw(rip_draw),
		  .plot(writeEn),
		  .operator(operator)
        );
		  
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
        .timer(timer),
        .erase(erase),
        .operator(operator),
        .rip_draw(rip_draw),
        .q_finish(q_finish),
        .o_finish(o_finish),
        .black(black),
        .rip_act(rip_act),
        .x_out(x),
        .y_out(y),
        .colour_out(colour)
    );	


    hex_decoder H0(
        .hex_digit(timer[3:0]), 
        .segments(HEX0)
        );
        
    hex_decoder H1(
        .hex_digit(timer[7:4]), 
        .segments(HEX1)
        );

    hex_decoder H2(
        .hex_digit(score[3:0]), 
        .segments(HEX2)
        );
        
    hex_decoder H3(
        .hex_digit(score[7:4]), 
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

module control(clk, resetn, go, go1, go2, correct, black, rip_act, o_finish, q_finish, ld_q1, ld_q2, ld_ans, erase, show_q, rip_draw, plot, operator);

    input clk;
    input resetn;
    input go;
    input go1;
    input go2;
    input correct, black, rip_act, o_finish, q_finish;


    output reg ld_q1;
    output reg ld_q2;
    output reg ld_ans;
    output reg erase; 
    output reg show_q;
    output reg rip_draw;
	 output reg plot, operator;

	reg [3:0] current_state, next_state;
	
	localparam 	Q1_GEN = 4'd0,
                Q1_GEN_WAIT = 4'd1,
                Q2_GEN = 4'd2,
                Q2_GEN_WAIT = 4'd3,
                DISPLAY = 4'd4,
                DISPLAY_WAIT = 4'd5,
                DISPLAY_DONE =4'd6,
                OPERATOR = 4'd7,
                OPERATOR_DONE = 4'd8,
                LOAD_NUM = 4'd9,
				LOAD_NUM_WAIT = 4'd10,
				RESULT = 4'd11,
				ERASE = 4'd12,
				RIP = 4'd13;


	always @(*)
	begin: state_table
		case (current_state)
            Q1_GEN: next_state = go ? Q1_GEN_WAIT : Q1_GEN;
            Q1_GEN_WAIT: next_state = go ? Q1_GEN_WAIT : Q2_GEN; 
            Q2_GEN: next_state = go ? Q2_GEN_WAIT : Q2_GEN;
            Q2_GEN_WAIT: next_state = go ? Q2_GEN_WAIT : DISPLAY;
            DISPLAY: next_state = go1 ? DISPLAY_WAIT : DISPLAY;
            DISPLAY_WAIT: next_state = go1? DISPLAY_WAIT : DISPLAY_DONE;
            DISPLAY_DONE: next_state = q_finish? OPERATOR : DISPLAY_DONE;
            OPERATOR: next_state = OPERATOR_DONE;
            OPERATOR_DONE: next_state = o_finish? LOAD_NUM: OPERATOR_DONE;
			LOAD_NUM: next_state = go2 ? LOAD_NUM_WAIT : LOAD_NUM;
			LOAD_NUM_WAIT: next_state = go2 ? LOAD_NUM_WAIT : RESULT;
            RESULT: next_state = correct? ERASE : RIP;
            ERASE: next_state = black ? Q1_GEN : ERASE;
            RIP: next_state = RIP;


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
        plot = 1'b0;
        erase = 1'b0;
        rip_draw = 1'b0;
        operator = 1'b0;

        case (current_state)
            Q1_GEN_WAIT: begin
                ld_q1 = 1'b1;
                end
            Q2_GEN_WAIT: begin
                ld_q2 = 1'b1;
                end
            DISPLAY_DONE: begin
                show_q = 1'b1;
                plot = 1'b1;
                end
            OPERATOR_DONE: begin
                operator = 1'b1;
                plot = 1'b1;
                end
            LOAD_NUM: begin
                ld_ans = 1'b1;
                end
            ERASE: begin
                erase = 1'b1;
                plot = 1'b1;
                end
            RIP: begin
                rip_draw = 1'b1;
                plot = 1'b1;
            end

        endcase
    end

    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= ERASE;
        else if (rip_act)
            current_state <= RIP;
        else 
            current_state <= next_state;
    end // state_FFS
endmodule
   

module datapath(clk, resetn, data_in, ld_ans, ld_q1, ld_q2, show_q, score, high_score, timer, erase, operator, rip_draw, 
    q_finish, o_finish, black, rip_act, x_out, y_out, colour_out);

    input clk;
    input resetn;
    input [7:0] data_in;
    input ld_ans;
    input ld_q1;
    input ld_q2;
    input show_q;
    input erase;
    input operator;
    input rip_draw;
    output reg [7:0] score = 0;
    output reg [7:0] high_score = 0;
    output reg [7:0] timer = 30;
    

    output q_finish, o_finish, black, rip_act;
    output [7:0] x_out;
    output [6:0] y_out;
    output [2:0] colour_out;

    
	 
    // wire
    wire better, correct;
	
    // input registers
    reg [7:0] in;
    reg [3:0] temp_q1 = 15;
    reg [3:0] temp_q2 = 15;

	 
	 reg [3:0] q1 = 4'b1111;
	 reg [3:0] q2 = 4'b1111;
    // time, scoreboard
    reg [27:0] counter;

    // alu_op
    reg [1:0] alu_op; 
    reg [1:0] temp_op = 3;

    // output of the alu
    reg [7:0] alu_out;

	 /*
    //Random number generator (Q1)
    wire feedback = temp_q1[3];

    always @(posedge clk)
    begin
      temp_q1[0] <= feedback;
      temp_q1[1] <= temp_q1[0];
      temp_q1[2] <= temp_q1[1];
      temp_q1[3] <= temp_q1[2] ^ feedback;
    end

    always @ (posedge clk) begin
        if (!resetn) begin
            q1 <= 1'b0;
        end
        else begin
            if (ld_q1)
                q1 <= temp_q1;
        end
    end


    //Random number generator (Q2)
    wire feedback2 = temp_q2[3];

    always @(posedge clk)
    begin
      temp_q2[0] <= feedback2;
      temp_q2[1] <= temp_q2[0];
      temp_q2[2] <= temp_q2[1];
      temp_q2[3] <= temp_q2[2] ^ feedback2;
    end

    always @ (posedge clk) begin
        if (!resetn) begin
            q2 <= 1'b0;
        end
        else begin
            if (ld_q2)
                q2 <= temp_q2;
        end
    end
	 */



    //Random number generator (ALU_OP)
    always @(posedge clk)
    begin
      temp_op[0] <= temp_op[1];
      temp_op[1] <= temp_op[0] ^ temp_op[1];
    end


    // Registers in, q1, q2, alu_op with respective input logic
    always @ (posedge clk) 
    begin
        if (!resetn) begin
            in <= 8'b0;
        end
        else if (ld_ans) begin
            in <= data_in;
            alu_op <= temp_op;
        end
    end
 

    reg op_plus, op_minus, op_multiply;
     // The ALU 
    always @(*)
    begin
        // alu
        case (alu_op)
            2'b10: begin
                   alu_out = q1 + q2; //performs addition
                   op_plus = 1'b1;
                end
            2'b01: begin
                   alu_out = q1 * q2; //performs multiplication
                   op_multiply = 1'b1;
                end
            2'b11: begin
                   alu_out = q1 - q2; //performs subtraction
                   op_minus = 1'b1;
                end
            default: begin
                    alu_out = 8'b0;
                    op_minus = 1'b0;
                    op_plus = 1'b0;
                    op_multiply = 1'b0;
                end
        endcase
    end 

 
    //Result comparator
    assign correct = (alu_out == in)? 1:0;
    assign rip_act1 = (alu_out == in)? 0:1;

    //High score comparator
    assign better = (score > high_score)? 1:0;


    //Score_counter
    always @ (posedge clk) begin
        if (!resetn || rip_act) begin
            score <= 8'b0;
            end
        else if (ld_ans) begin
            if (correct)
            score <= score + 1'b1;
            if (better)
            high_score <= score;
        end
    end

    wire rip_act2;
	 
    //Time_counter
    always @(posedge clk)
    begin
        if (resetn == 1'b0)
			begin
				timer <= 8'b0001_1110;
				counter <= 1'd0;
			end
		  else if (show_q) begin
			  if (counter == 27'b0) begin
					 counter <= 49_999_999;
					 timer <= timer - 1'b1;
					 end
			  else
					begin
					counter <= counter - 1'b1;
					end
			end
	end

    assign rip_act2 = (timer==1'b0)? 1:0;
	


    reg [7:0] x_in;
    reg [6:0] y_in;
    reg [7:0] reset_counter1 = 159;
    reg [6:0] reset_counter2 = 30;
     
    // x reset counter for painting everything black
    always @(posedge clk)
    begin   
        if (!resetn)
            reset_counter1 <= 8'd159;   //thats why there are 160 bits for x
            //reset_counter1 <= 8'd10;
        else if (erase) begin
            if (reset_counter1 == 8'd0)
                reset_counter1 <= 8'd159;
            else
                reset_counter1 <= reset_counter1 - 1'b1;
        end
    end

    // y reset counter for painting everything black
    always @(posedge clk)
    begin   
        if (!resetn)
            reset_counter2 <= 7'd119;
            //reset_counter2 <= 8'd10;
        else if (reset_counter1 == 8'd0)  //thats why its depending on x to finish the row
            reset_counter2 <= reset_counter2 - 1'b1;
    end


    reg [1:0] location = 0;
    reg number = 0;
	 
	 reg op_plus_begin = 1'b1;
    reg op_minus_begin = 1'b1; 
    reg op_multiply_begin = 1'b1;

    reg done_op = 1'b0;
    reg down, up = 1'b0;
    //input operator

    reg rip_begin = 1'b1;
    reg high, low = 1'b0;
    //rip_draw
	 
	 
    reg one = 1'b0; 
    reg zero = 1'b0;
	 reg one_start = 1'b1;
	 reg zero_start = 1'b1;
	 
	 
	 reg [2:0] total_loc = 0;
	 //total location
	 always @(*)
    begin
        case (total_loc)
            3'b000: begin
                   location = 2'b00;
                   number = 0;
						 one = (q1[0] == 1)? 1:0;
						 zero = (q1[0] == 0)? 1:0;
                end
            3'b001: begin
                   location = 2'b01;
                   number = 0;
						 one = (q1[1] == 1)? 1:0;
						 zero = (q1[1] == 0)? 1:0;
                end
            3'b010: begin
                   location = 2'b10;
                   number = 0;
						 one = (q1[2] == 1)? 1:0;
						 zero = (q1[2] == 0)? 1:0;
                end
            3'b011: begin
                   location = 2'b11;
                   number = 0;
						 one = (q1[3] == 1)? 1:0;
						 zero = (q1[3] == 0)? 1:0;
                end
            3'b100: begin
                   location = 2'b00;
                   number = 1;
						 one = (q2[0] == 1)? 1:0;
						 zero = (q2[0] == 0)? 1:0;
                end
            3'b101: begin
                   location = 2'b01;
                   number = 1;
						 one = (q2[1] == 1)? 1:0;
						 zero = (q2[1] == 0)? 1:0;
                end
            3'b110: begin
                   location = 2'b10;
                   number = 1;
						 one = (q2[2] == 1)? 1:0;
						 zero = (q2[2] == 0)? 1:0;
                end
            3'b111: begin
                   location = 2'b11;
                   number = 1;
						 one = (q2[3] == 1)? 1:0;
						 zero = (q2[3] == 0)? 1:0;
                end
            default: begin
						location = 1'b0;
						number = 1'b0;
						one = 1'b0;
						zero = 1'b0;
            end
        endcase
    end 
	 
	 //x_in and y_in for each condition
    always @(posedge clk)
    begin
				if (!resetn) begin
					op_plus_begin <= 1'b1;
					op_minus_begin <= 1'b1; 
					op_multiply_begin <= 1'b1;
					rip_begin <= 1'b1;
					total_loc <= 1'b0;
					one_start <= 1'd1;
					zero_start <= 1'd1;
            end
				
				else if (show_q) begin
					if (one) begin
						 if (one_start) begin
							  x_in <= 19 + (location) * 10 + 9; //digit is the digit of the number (e.g. in 0100 digit of "1" = 2)
							  y_in <= 29 + (number) * 30; //number is the number of the question (q1 = 1 and q2 = 2)
							  one_start <= 1'd0;
						 end
						 
						 else if (y_in <= 29 + (number) * 30 + 20) begin
							  y_in <= y_in + 7'd1;
							  if (y_in == 29 + (number) * 30 + 20) begin
									total_loc <= total_loc + 1'b1;
									one_start <= 1'b1;
								end
						 end
					end
					
					else if (zero) begin
						 if (zero_start) begin
							  x_in <= 19 + (location) * 10 + 2;
							  y_in <= 29 + (number) * 30;
							  zero_start <= 1'd0;
						 end
						 else if (y_in == 29 + (number) * 30) begin
							  x_in <= x_in + 8'd1;
							  if (x_in == 19 + (location+1) * 10 -1) begin
									x_in <= 19 + (location) * 10 + 1;
									y_in <= y_in + 7'd1;
							  end
						 end
						 else if (x_in == 19 + (location) * 10 + 1) begin
							  y_in <= y_in + 7'd1;
							  if (y_in == 29 + (number) * 30 + 20) begin
									x_in <= 19 + (location) * 10 + 9;
									y_in <= 29 + (number) * 30 + 1;
							  end
						end
						else if (x_in == 19 + (location) * 10 + 9) begin
							  y_in <= y_in + 7'd1;
							  if (y_in == 29 + (number) * 30 + 20) begin
									x_in <= 19 + (location) * 10 + 2;
									y_in <= 29 + (number) * 30 + 20;
							  end
						end
						else if (y_in == 29 + (number) * 30 + 20) begin
								x_in <= x_in + 8'd1;
							  if (x_in == 19 + (location+1) * 10 -1) begin
									total_loc <=  total_loc + 1'b1;
									zero_start <= 1'b1;
							  end
						 end
					end
				end
				
				else if (operator) begin
					if (op_plus) begin
							 if (op_plus_begin) begin
							 x_in <= 8'd10;
							 y_in <= 7'd69;
							 op_plus_begin <= 1'd0;
							 end
							 else if (y_in == 7'd69) begin
								  x_in <= x_in + 8'd1;
								  if (x_in == 8'd19) begin
										x_in <= 8'd14;
										y_in <= 7'd64;
								  end
							 end
							 else if (x_in == 14 && y_in != 7'd69) begin
								  y_in <= y_in + 7'd1;
								  if (y_in == 7'd69) begin
										y_in <= y_in + 7'd1;
								  end
								  else if (y_in == 7'd74) begin
										done_op = 1'b1;
								  end
							 end
						end
			  
					else if (op_minus) begin
						 if (op_minus_begin) begin
							  x_in <= 8'd10;
							  y_in <= 7'd69;
							  op_minus_begin <= 1'd0;
						 end
						 else if (y_in == 7'd69) begin
							  x_in <= x_in + 8'd1;
							  if (x_in == 8'd18) begin
									done_op <= 1'b1;
							  end
						 end
					end
			  
					else if (op_multiply) begin
						 if (op_multiply_begin) begin
							  x_in <= 8'd10;
							  y_in <= 7'd64;
							  op_multiply_begin <= 1'd0;
							  down <= 1'd1;
						 end
						 else if (down) begin
							  x_in <= x_in + 1'd1;
							  y_in <= y_in + 1'd1;
							  if (x_in == 8'd19) begin
									x_in <= 8'd10;
									y_in <= y_in - 7'd1;
									down <= 1'd0;
									up <= 1'd1;
							  end
						 end
						 else if (up) begin
							  x_in <= x_in + 1'd1;
							  y_in <= y_in - 1'd1;
							  if (x_in == 8'd18) begin
									up <= 1'd0;
									done_op <= 1'd1;
							  end
						 end
					end
			  end
		  
		  else if (rip_draw) begin
            if (rip_begin) begin
                x_in <= 8'd24;
                y_in <= 7'd9;
                rip_begin <= 1'd0;
                low <= 1'd1;
            end
            else if (low) begin
                x_in <= x_in + 1'd1;
                y_in <= y_in + 1'd1;
                if (x_in == 8'd124) begin
                    x_in <= 8'd24;
                    y_in <= y_in - 7'd1;
                    low <= 1'd0;
                    high <= 1'd1;
                end
            end
            else if (high) begin
                x_in <= x_in + 1'd1;
                y_in <= y_in - 1'd1;
                if (x_in == 8'd123) begin
                    high <= 1'd0;
                end
            end
        end
    end
  

    assign rip_act = rip_act1 || rip_act2;
    assign x_out = erase ? reset_counter1: x_in;
    assign y_out = erase ? reset_counter2: y_in;
    assign colour_out = erase ? 3'b000: 3'b111;    //if erase, choose color black
    assign black = !reset_counter1 & !reset_counter2;  //only completely black when both reset_counter are zero
    assign q_finish = (number == 1) && (location == 3); //finish question
    assign o_finish = (done_op == 1'b1)? 1:0;
    
endmodule


