module send_cmd(
	input clk,
	input reset_n,
	
	input en,
	
	input write,
	input [7:0] data,
	
	output write_complete,
	output reg sck,
	output reg spi_do
);
	
	parameter c0 = 0, c1 = 1, c2 = 2, c3 = 3, c4 = 4, c5 = 5,c6 = 6, c7 = 7;
	parameter done = 8;
	reg [3:0] state, next_state;
	
	//SDK Generater
	reg [10:0] counter;
	always@(posedge clk,negedge reset_n)begin
		if(!reset_n) counter <= 11'h00;
		else if(counter == `sck_counter_max) counter <= 11'h0;
		else if(en) begin
			counter <= counter + 11'h1;
		end
		else counter <= 11'h0;
	end
	
	always@(posedge clk, negedge reset_n)begin
		if(!reset_n) sck <= 1'b0;
		else begin
			if(counter > `sck_counter_half) sck <= 1'b1;
			else sck <= 1'b0;
		end
	end
	
	//--FSM--//
	//Passing
	always@(posedge clk, negedge reset_n)begin
		if(!reset_n) state <= 3'd0;
		else if(en) state <= next_state;
		else state <= 3'd0;
	end
	
	//Transistion
	always@(*)begin
		case(state)
			
			c0: next_state = (counter == `sck_counter_max) ? c1: c0;
			c1: next_state = (counter == `sck_counter_max) ? c2: c1;
			c2: next_state = (counter == `sck_counter_max) ? c3: c2;
			c3: next_state = (counter == `sck_counter_max) ? c4: c3;
			c4: next_state = (counter == `sck_counter_max) ? c5: c4;
			c5: next_state = (counter == `sck_counter_max) ? c6: c5;
			c6: next_state = (counter == `sck_counter_max) ? c7: c6;
			c7: next_state = (counter == `sck_counter_max) ? done: c7;
			
			done: next_state = c0;
			
			default: next_state = c0;
		endcase
	end
	
	//Execute
	always@(*)begin
		case(state)
			
			c0: spi_do = data[7];
			c1: spi_do = data[6];
			c2: spi_do = data[5];
			c3: spi_do = data[4];
			c4: spi_do = data[3];
			c5: spi_do = data[2];
			c6: spi_do = data[1];
			c7: spi_do = data[0];
			
			done: spi_do = 1'b0;
			
			default: spi_do = 1'b0;
			
		endcase
	end
	
	assign write_complete = (state == done);
	
endmodule 