	//x_in & y_in coords
	always @(posedge clock)
	begin
		if (!reset_n)
			x_in <= 8'd0;
			y_in <= 7'd0;
		end
		
		begin
		else if (timer_outline)
			begin
			if (timer_outline_start)
				x_in <= 8'd4;
				y_in <= 7'd4;
				timer_outline_start <= 1'd0;
			end
			begin
			else if (y_in == 7'd4)
				x_in <= x_in + 8'd1;
				begin
				if (x_in == 8'd155)
					x_in <= 8'd4;
					y_in <= 7'd5;
				end
			end
			begin
			else if (y_in > 7'd4 && y_in < 7'd29)
				y_in <= y_in + 7'd1;
				begin
				if (x_in == 8'd4 && y_in == 7'd29)
					x_in == 8'd154;
					y_in == 7'd5;
				end
				begin
				else if (x_in == 8'd154 && y_in == 7'd29)
					x_in <= 8'd4;
				end
			end
			begin
			else if (y_in == 7'd29)
				x_in <= x_in + 8'd1;
				begin
				if (x_in == 8'd154)
					timer_outline <= 1'd0;
				end
			end
		end
		
		begin
		else if (timer_box)
			begin
			if (timer_box_start)
				x_in <= (30 - current_time + 1) * 5 + 4;
				y_in <= 7'd4;
				timer_box_start <= 1'd0;
			end
			begin
			else
				x_in <= x_in + 8'd1;
				begin
				if (x_in == (30 - current_time + 2) * 5 + 4)
					x_in <= (30 - current_time + 1) * 5 + 4;
					y_in <= y_in + 7'd1;
				end
				begin
				else if (x_in == (30 - current_time + 2) * 5 + 3 && y_in == 7'd29)
					timer_box <= 1'd0;
				end
			end
		end
		
		begin
		else if (one)
			begin
			if (one_start)
				x_in <= 119 + (digit - 1) * 10 + 9; //digit is the digit of the number (e.g. in 0100 digit of "1" = 2)
				y_in <= 59 + (number - 1) * 30; //number is the number of the question (q1 = 1 and q2 = 2)
				one_start <= 1'd0;
			end
			begin
			else
				y_in <= y_in + 7'd1;
				begin
				if (y_in == 59 + (number - 1) * 30 + 20)
					one <= 1'd0;
				end
			end
		end
		
		begin
		else if (zero)
			begin
			if (zero_start)
				x_in <= 119 + (digit - 1) * 10 + 1;
				y_in <= 59 + (number - 1) * 30;
				zero_start <= 1'd0;
			end
			begin
			else if (y_in == 59 + (number - 1) * 30)
				x_in <= x_in + 8'd1;
				begin
				if (x_in == 119 + digit * 10)
					x_in <= 119 + (digit - 1) * 10 + 1;
					y_in <= y_in + 7'd1;
				end
			end
			begin
			else if (y_in > 59 + (number - 1) * 30 && y_in < 59 + (number - 1) * 30 + 20)
				y_in <= y_in + 7'd1;
				begin
				if (x_in == 119 + (digit - 1) * 10 + 1 && y_in == 59 + (number - 1) * 30 + 20)
					x_in <= 119 + (digit - 1) * 10 + 9;
					y_in <= 59 + (number - 1) * 30 + 1;
				end
				begin
				else if (x_in == 119 + (digit - 1) * 10 + 9 && y_in == 59 + (number - 1) * 30 + 20)
					x_in <= 119 + (digit - 1) * 10 + 1;
				end
			else if (y_in == 59 + (number - 1) * 30 + 20)
				x_in <= x_in + 8'd1;
				begin
				if (x_in == 119 + (digit - 1) * 10 + 9)
					zero <= 1'd0;
				end
			end
		end
		
		begin
		else if (op_plus)
			begin
			if (op_plus_begin)
				x_in <= 8'd110;
				y_in <= 7'd99;
				op_plus_begin <= 1'd0;
			end
			begin
			else if (y_in == 7'd99)
				x_in <= x_in + 8'd1;
				begin
				if (x_in == 8'd119)
					x_in <= 8'd114;
					y_in <= 7'd94;
				end
			end
			begin
			else if (x_in == 114 && y_in != 7'd99)
				y_in <= y_in + 7'd1;
				begin
				if (y_in == 7'd99)
					y_in <= y_in + 7'd1;
				end
				begin
				else if (y_in == 7'd104)
					op_plus <= 1'd0;
				end
			end
		end
		
		begin
		else if (op_minus)
			begin
			if (op_minus_begin)
				x_in <= 8'd110;
				y_in <= 7'd99;
				op_minus_begin <= 1'd0;
			end
			begin
			else if (y_in == 7'd99)
				x_in <= x_in + 8'd1;
				begin
				if (x_in == 8'd118)
					op_minus <= 1'd0;
				end
			end
		end
		
		begin
		else if (op_multiply)
			begin
			if (op_multiply_begin)
				x_in <= 8'd110;
				y_in <= 7'd94;
				op_multiply_begin <= 1'd0;
				down <= 1'd1;
			end
			begin
			else if (down)
				x_in <= x_in + 8'd1;
				y_in <= y_in + 7'd1;
				begin
				if (x_in == 8'd119)
					x_in <= 8'd110;
					y_in <= y_in - 7'd1;
					down <= 1'd0;
					up <= 1'd1;
				end
			end
			begin
			else if (up)
				x_in <= x_in + 8'd1;
				y_in <= y_in - 7'd1;
				begin
				if (x_in == 8'd118)
					down <= 1'd0;
					op_multiply <= 1'd0;
				end
			end
	end