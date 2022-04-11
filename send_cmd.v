module send_cmd(
	input clk,
	input reset_n,
	
	input en,
	
	input write,
	input [7:0] write_data,
	
	output write_complete,
	output sck,
	output spi_do
);
	
	parameter c0 = 0, c1 = 1, c2 = 2, c3 = 3, c4 = 4, c5 = 5,c6 = 6, c7 = 7;
	parameter done = 8;
	reg [2:0] state,next_state;
	
	//SDK Generater
	reg [4:0] counter;
	always@(posedge clk,negedge reset_n)begin
		if(!reset_n) counter <= 5'h00;
		else if(counter == sck_counter_max) counter <= 5'h0;
		else if(!write_complete && en) begin
			counter <= counter + 5'h1;
			
			if(counter < 5'h0f) sck <= 1'b0;
			else sck <= 1'b1;
			
		end
		else counter <= 5'h0;
	end
	
	//--FSM--//
	//Passing
	always@(posedge clk, negedge reset_n)begin
		if(!reset_n) state <= 3'd0;
		else state <= next_state;
	end
	
	//Transistion
	always@(*)begin
		case(state)
			
			c0: next_state = (counter == sck_counter_max) ? c1: c0;
			c1: next_state = (counter == sck_counter_max) ? c2: c1;
			c2: next_state = (counter == sck_counter_max) ? c3: c2;
			c3: next_state = (counter == sck_counter_max) ? c4: c3;
			c4: next_state = (counter == sck_counter_max) ? c5: c4;
			c5: next_state = (counter == sck_counter_max) ? c6: c5;
			c6: next_state = (counter == sck_counter_max) ? c7: c6;
			c7: next_state = (counter == sck_counter_max) ? done: c7;
			
			done: next_state = c0;
			
			default: next_state = c0;
			
		endcase
	end
	
	//Execute
	always@(*)begin
		case(state)
			
			c0: 
			c1:
			c2:
			c3:
			c4:
			c5:
			c6:
			c7:
			
			done: 
			
			default: 
			
		endcase
	end
	
endmodule 