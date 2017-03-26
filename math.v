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



module control();
	localparam 	DISPLAY = 4'b0000;
				LOAD_NUM_WAIT = 4'b0001;
				RESULT = 4'b0002;
				RIP = 4'b0003;


	always @(*)
	begin: state_table
		case (current_state)
			DISPLAY: next_state = load_ans ? LOAD_NUM_WAIT : DISPLAY;
			LOAD_NUM_WAIT: next_state = load_ans ? RIP : LOAD_NUM_WAIT;
			RIP: next_state = DISPLAY;
		default: next_state = DISPLAY;
		endcase
	end


    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        load_ans = 1'b0;

        case (current_state)
            DISPLAY: begin
                load_ans = 1'b1;
                end
            RIP: begin
                //set cur_score if right
                //set high_score if wrong and cur_score > high_score
                //set rip_counter to nanosec if right, 120 sec if wrong

                end
            end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals

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
    input alu_op, 
    input enable,
    output reg [7:0] data_result,
    output reg [2:0] score,
    output reg [1:0] time
    );
    
    // input registers
    reg [7:0] in, q1, q2, temp_q1, temp_q2;

    // time, scoreboard
    reg [1:0] time;
    reg [2:0] score;

    // alu_op
    reg [1:0] alu_op, temp_op;


    // output of the alu
    reg [7:0] alu_out;

    //Random number generator (Questions)

    //Random number generator (ALU_OP)


    // Registers a, b, c, x with respective input logic
    always @ (posedge clk) begin
        if (!resetn) begin
            in <= 8'd0; 
            q1 <= 8'd0; 
            q2 <= 8'd0;  
        end
        else begin
            if (ld_ans)
                in <= data_in;
                q1 <= temp_q1;
                q2 <= temp_q2;
                alu_op <= temp_op;
        end
    end
 
 
    //8-bit comparator

    //Score_counter
    always @ (posedge clk) begin
        if (!reset) begin
            score <= 3'd0;
            end
        else begin
            if (enable)
            score <= score + 3'd1;
        end
    end

    //Time_counter
    always @ (posedge clk) begin
        if (!reset) begin
            time <= 2'd30;
            end
        else begin
            if (enable)
            time <= time - 2'd1;
        end
    end

    //RIP_counter

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
                   alu_out = q1 - q2; //performs multiplication
                end
            default: alu_out = 8'd0;
        endcase
    end

    //
    
endmodule


