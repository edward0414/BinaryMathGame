// User guide
//go: load q1 and q2  KEY[3]
//go1: show question  KEY[2]
//go2: enter your answer  KEY[1]
//resetn               KEY[0]
//data_in              SW[7-0]
//Enter your answer when the question shows up. If correct, screen turns black and you get one point. Restart.
//If not correct, screen turns rip. You have to manually reset.

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
    
      

    // Put your code here. Your code should produce signals x,y,colour and writeEn/plot
    // for the VGA controller, in addition to any other functionality your design may require.
    
    wire [7:0] score;
    wire [7:0] timer;
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
        .timer(timer)
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

module control(clk, resetn, go, go1, go2, correct, black, rip_act, finish, ld_q1, ld_q2, ld_ans, erase, show_q, rip_draw);

    input clk;
    input resetn;
    input go;
    input go1;
    input go2;
    input correct, black,, rip_act, finish;


    output reg ld_q1;
    output reg ld_q2;
    output reg ld_ans;
    output reg erase; 
    output reg show_q;
    output reg rip_draw;

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
				RIP = 4'd11;


	always @(*)
	begin: state_table
		case (current_state)
            Q1_GEN: next_state = go ? Q1_GEN_WAIT : Q1_GEN;
            Q1_GEN_WAIT: next_state = go ? Q1_GEN_WAIT : Q2_GEN; 
            Q2_GEN: next_state = go ? Q2_GEN_WAIT : Q2_GEN;
            Q2_GEN_WAIT: next_state = go ? Q2_GEN_WAIT : DISPLAY;
            DISPLAY: next_state = go1 ? DISPLAY_WAIT : DISPLAY;
            DISPLAY_WAIT: next_state = go1? DISPLAY_WAIT : DISPLAY_PLOT;
            DISPLAY_DONE: next_state = q_finish? OPERATOR : DISPLAY_PLOT;
            OPERATOR: next_state = OPERATOR_PLOT;
            OPERATOR_DONE: next_state = o_finish? LOAD_NUM: OPERATOR_PLOT;
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
    always@(posedge clock)
    begin: state_FFs
        if(!reset_n)
            current_state <= ERASE;
        else if (rip_act)
            current_state <= RIP;
        else 
            current_state <= next_state;
    end // state_FFS
endmodule
   

module datapath(clk, resetn, data_in, ld_ans, ld_q1, ld_q2, show_q, score, high_score, timer, erase, operator, rip_draw, 
    q_finish, o_finish, black, rip_act);

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
    reg [3:0] q1, q2; 
    reg [3:0] temp_q1 = 15;
    reg [3:0] temp_q2 = 15;

    // time, scoreboard
    reg [27:0] counter;

    // alu_op
    reg [1:0] alu_op; 
    reg [1:0] temp_op = 3;

    // output of the alu
    reg [7:0] alu_out;


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

    wire rip_act2 = 1'b0;
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
    always @(posedge clock)
    begin   
        if (!reset_n)
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
    always @(posedge clock)
    begin   
        if (!reset_n)
            reset_counter2 <= 7'd119;
            //reset_counter2 <= 8'd10;
        else if (reset_counter1 == 8'd0)  //thats why its depending on x to finish the row
            reset_counter2 <= reset_counter2 - 1'b1;
    end


    reg [1:0] location = 0;
    reg number = 1'd0;
    reg done_dig = 1'd0;  

    //location counter
    always (posedge clk)
    begin
        if (!resetn)
            location <= 1'b0;

        else if (done_dig) begin
            location <= location + 1'b1;
            done_dig <= 1'd0;
            if (location == 3) begin
                location <= 2'b0;
                number <= 1'd1;
            end
        end
    end

    reg one = 1'b0; 
    reg zero = 1'b0;

    //determine if a digit is one or zero
    always @(posedge clk) begin
        if (!resetn) begin
            one <= 1'b0;
            zero <= 1'b0;
        end
        else if (show_q) begin
            
        end
    end

    always @(posedge clk)
    begin
            if (one) begin
                if (one_start) begin
                    x_in <= 119 + (location) * 10 + 9; //digit is the digit of the number (e.g. in 0100 digit of "1" = 2)
                    y_in <= 59 + (number) * 30; //number is the number of the question (q1 = 1 and q2 = 2)
                    one_start <= 1'd0;
                end
                
                else begin
                    y_in <= y_in + 7'd1;
                    if (y_in == 59 + (number) * 30 + 20)
                        done_dig <= 1'd1;
                end
            end
            
            else if (zero) begin
                if (zero_start) begin
                    x_in <= 119 + (location) * 10 + 1;
                    y_in <= 59 + (number) * 30;
                    zero_start <= 1'd0;
                end
                else if (y_in == 59 + (number) * 30) begin
                    x_in <= x_in + 8'd1;
                    if (x_in == 119 + (location+1) * 10) begin
                        x_in <= 119 + (location) * 10 + 1;
                        y_in <= y_in + 7'd1;
                    end
                end
                else if (y_in > 59 + (number) * 30 && y_in < 59 + (number) * 30 + 20) begin
                    y_in <= y_in + 7'd1;
                    if (x_in == 119 + (location) * 10 + 1 && y_in == 59 + (number) * 30 + 20) begin
                        x_in <= 119 + (location) * 10 + 9;
                        y_in <= 59 + (number) * 30 + 1;
                    end
                    else if (x_in == 119 + (location) * 10 + 9 && y_in == 59 + (number) * 30 + 20) begin
                        x_in <= 119 + (location) * 10 + 1;
                    end
                end
                else if (y_in == 59 + (number) * 30 + 20) begin
                    x_in <= x_in + 8'd1;
                    if (x_in == 119 + (location) * 10 + 9) begin
                        done_dig <= 1'd1;
                    end
                end
            end
    end
  

    reg op_plus_begin = 1'b1;
    reg op_minus_begin = 1'b1; 
    reg op_multiply_begin = 1'b1;

    reg done_op = 1'b0;
    reg down, up = 1'b0;
    //input operator
    always @(posedge clk)
    begin
        if (operator) begin
            if (op_plus) begin
                if (op_plus_begin) begin
                x_in <= 8'd110;
                y_in <= 7'd99;
                op_plus_begin <= 1'd0;
                end
                else if (y_in == 7'd99) begin
                    x_in <= x_in + 8'd1;
                    if (x_in == 8'd119) begin
                        x_in <= 8'd114;
                        y_in <= 7'd94;
                    end
                end
                else if (x_in == 114 && y_in != 7'd99) begin
                    y_in <= y_in + 7'd1;
                    if (y_in == 7'd99) begin
                        y_in <= y_in + 7'd1;
                    end
                    else if (y_in == 7'd104) begin
                        done_op = 1'b1;
                    end
                end
            end
        
            else if (op_minus) begin
                if (op_minus_begin) begin
                    x_in <= 8'd110;
                    y_in <= 7'd99;
                    op_minus_begin <= 1'd0;
                end
                else if (y_in == 7'd99) begin
                    x_in <= x_in + 8'd1;
                    if (x_in == 8'd118) begin
                        done_op <= 1'b1;
                    end
                end
            end
        
            else if (op_multiply) begin
                if (op_multiply_begin) begin
                    x_in <= 8'd110;
                    y_in <= 7'd94;
                    op_multiply_begin <= 1'd0;
                    down <= 1'd1;
                end
                else if (down) begin
                    x_in <= x_in + 1'd1;
                    y_in <= y_in + 1'd1;
                    if (x_in == 8'd119) begin
                        x_in <= 8'd110;
                        y_in <= y_in - 7'd1;
                        down <= 1'd0;
                        up <= 1'd1;
                    end
                end
                else if (up) begin
                    x_in <= x_in + 1'd1;
                    y_in <= y_in - 1'd1;
                    if (x_in == 8'd118) begin
                        down <= 1'd0;
                        done_op <= 1'd1;
                    end
                end
            end
        end
    end

    //rip_draw
    always @(posedge clk) 
    begin
        if (rip_draw) begin
            
        end
    end

    assign rip_act = rip_act1 || rip_act2;
    assign x_out = erase ? reset_counter1: x_in;
    assign y_out = erase ? reset_counter2: y_in;
    assign colour_out = erase ? 3'b000: 3'b111;    //if erase, choose color black
    assign black = !reset_counter1 & !reset_counter2;  //only completely black when both reset_counter are zero
    assign q_finish = //finish question
    assign o_finish = (done_op == 1'b1)? 1:0;
    
endmodule


