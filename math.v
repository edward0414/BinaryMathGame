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
    input ld_alu_out, 
    input ld_x, ld_a, ld_b, ld_c,
    input ld_r,
    input alu_op, 
    input [1:0] alu_select_a, alu_select_b,
    output reg [7:0] data_result
    );
    
    // input registers
    reg [7:0] a, b, c, x;

    // output of the alu
    reg [7:0] alu_out;
    // alu input muxes
    reg [7:0] alu_a, alu_b;
    
    // Registers a, b, c, x with respective input logic
    always @ (posedge clk) begin
        if (!resetn) begin
            a <= 8'd0; 
            b <= 8'd0; 
            c <= 8'd0; 
            x <= 8'd0; 
        end
        else begin
            if (ld_a)
                a <= ld_alu_out ? alu_out : data_in; // load alu_out if load_alu_out signal is high, otherwise load from data_in
            if (ld_b)
                b <= ld_alu_out ? alu_out : data_in; // load alu_out if load_alu_out signal is high, otherwise load from data_in
            if (ld_x)
                x <= data_in;

            if (ld_c)
                c <= data_in;
        end
    end
 
    // Output result register
    always @ (posedge clk) begin
        if (!resetn) begin
            data_result <= 8'd0; 
        end
        else 
            if(ld_r)
                data_result <= alu_out;
    end

    // The ALU input multiplexers
    always @(*)
    begin
        case (alu_select_a)
            2'd0:
                alu_a = a;
            2'd1:
                alu_a = b;
            2'd2:
                alu_a = c;
            2'd3:
                alu_a = x;
            default: alu_a = 8'd0;
        endcase

        case (alu_select_b)
            2'd0:
                alu_b = a;
            2'd1:
                alu_b = b;
            2'd2:
                alu_b = c;
            2'd3:
                alu_b = x;
            default: alu_b = 8'd0;
        endcase
    end

    // The ALU 
    always @(*)
    begin : ALU
        // alu
        case (alu_op)
            0: begin
                   alu_out = alu_a + alu_b; //performs addition
               end
            1: begin
                   alu_out = alu_a * alu_b; //performs multiplication
               end
            default: alu_out = 8'd0;
        endcase
    end
    
endmodule


