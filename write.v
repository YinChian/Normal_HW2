module writer(
	input clk,
	input reset_n,
	
	input en,
	
	input write,		//Ok to write next signal
	input [7:0] data,
	
	output write_complete,
	output reg sck,
	output reg spi_do,
	
	output total_done
);

	//SDK Generater
	reg [10:0] counter;
	always@(posedge clk,negedge reset_n)begin
		if(!reset_n) counter <= 11'h00;
		else if(counter == `sck_counter_max) counter <= 11'h0;
		else if(en && (state != cmd_complete && state != addr_complete && state != done)) begin
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
	parameter c0 = 0 , c1 = 1 , c2 = 2 , c3 = 3 , c4 = 4 , c5 = 5 , c6 = 6 , c7 = 7 ;
	parameter a0 = 8 , a1 = 9 , a2 = 10, a3 = 11, a4 = 12, a5 = 13, a6 = 14, a7 = 15;
	parameter d0 = 16, d1 = 17, d2 = 18, d3 = 19, d4 = 20, d5 = 21, d6 = 22, d7 = 23;
	parameter done = 24, cmd_complete = 25, addr_complete = 26;
	
	reg [4:0] state, next_state;
	
	//Passing
	always@(posedge clk,negedge reset_n)begin
		if(!reset_n) state <= 5'd0;
		else if(en) state <= next_state;
		else state <= 5'd0;
	end
	
	//Transistion
	always@(*)begin
	
			case(state)
			
				//send command
				c0 : next_state = (counter == `sck_counter_max) ? c1 : c0;
				c1 : next_state = (counter == `sck_counter_max) ? c2 : c1;
				c2 : next_state = (counter == `sck_counter_max) ? c3 : c2;
				c3 : next_state = (counter == `sck_counter_max) ? c4 : c3;
				c4 : next_state = (counter == `sck_counter_max) ? c5 : c4;
				c5 : next_state = (counter == `sck_counter_max) ? c6 : c5;
				c6 : next_state = (counter == `sck_counter_max) ? c7 : c6;
				c7 : next_state = (counter == `sck_counter_max) ? cmd_complete : c7;
				
				cmd_complete: next_state = (write == 1'b1) ? a0 : cmd_complete;
				
				//send address
				a0 : next_state = (counter == `sck_counter_max) ? a1 : a0;
				a1 : next_state = (counter == `sck_counter_max) ? a2 : a1;
				a2 : next_state = (counter == `sck_counter_max) ? a3 : a2;
				a3 : next_state = (counter == `sck_counter_max) ? a4 : a3;
				a4 : next_state = (counter == `sck_counter_max) ? a5 : a4;
				a5 : next_state = (counter == `sck_counter_max) ? a6 : a5;
				a6 : next_state = (counter == `sck_counter_max) ? a7 : a6;
				a7 : next_state = (counter == `sck_counter_max) ? addr_complete : a7;
				
				addr_complete: next_state = (write == 1'b1) ? d0 : addr_complete;
				
				//send data
				d0 : next_state = (counter == `sck_counter_max) ? d1 : d0;
				d1 : next_state = (counter == `sck_counter_max) ? d2 : d1;
				d2 : next_state = (counter == `sck_counter_max) ? d3 : d2;
				d3 : next_state = (counter == `sck_counter_max) ? d4 : d3;
				d4 : next_state = (counter == `sck_counter_max) ? d5 : d4;
				d5 : next_state = (counter == `sck_counter_max) ? d6 : d5;
				d6 : next_state = (counter == `sck_counter_max) ? d7 : d6;
				d7 : next_state = (counter == `sck_counter_max) ? done : d7;
				
				done: next_state = c0;
				
				default: next_state = c0;
				
			endcase
	end
	
	//Execute -- Send Out Data
	always@(posedge clk,negedge reset_n)begin
		if(!reset_n) spi_do <= 1'b0;
		else begin
			case(state)
			
				//send command
				c0 : spi_do <= data[7];
				c1 : spi_do <= data[6];
				c2 : spi_do <= data[5];
				c3 : spi_do <= data[4];
				c4 : spi_do <= data[3];
				c5 : spi_do <= data[2];
				c6 : spi_do <= data[1];
				c7 : spi_do <= data[0];
				
				//send address
				a0 : spi_do <= data[7];
				a1 : spi_do <= data[6];
				a2 : spi_do <= data[5];
				a3 : spi_do <= data[4];
				a4 : spi_do <= data[3];
				a5 : spi_do <= data[2];
				a6 : spi_do <= data[1];
				a7 : spi_do <= data[0];
				
				//send data
				d0 : spi_do <= data[7];
				d1 : spi_do <= data[6];
				d2 : spi_do <= data[5];
				d3 : spi_do <= data[4];
				d4 : spi_do <= data[3];
				d5 : spi_do <= data[2];
				d6 : spi_do <= data[1];
				d7 : spi_do <= data[0];
				
				default: spi_do <= spi_do;
				
			endcase
		end
	end
	
	//write complete signal
	assign write_complete = (state == cmd_complete || state == addr_complete || state == done) ? 1'b1 : 1'b0;
	assign total_done = state == done;
	
endmodule 