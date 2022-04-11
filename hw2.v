`define code_wren  8'h06
`define code_write 8'h02
`define code_read  8'h03

`define sck_counter_max = 5'h1f


module hw2(
	//System
	input  clk_50M,
	input  reset_n,
	
	//Control
	input  write,
	output read,
	
	//State
	output write_complete,
	output read_complete,
	
	//Data
	input  [7:0] write_value,		//write value ---process---> DO
	output [7:0] read_value,		//read value  <---process--- SI
											//only exsists while reading
	
	//Signals
	output reg spi_csn,				//-CS--// Chip Select
	output reg spi_sck,				//-SCK-// clock
	output reg spi_do,				//-SI--// slave in
	input  reg spi_di					//-DO--// slave out
	
);
	
	//Parameter
	parameter init = 0, decode = 1, wren = 2, read = 3, write = 4;
	reg [1:0] state, next_state;
	
	//Passing
	always@(posedge clk_50M,negedge reset_n)begin
		if(!reset_n) state <= 2'b0;
		else state <= next_state; 
	end
	
	//Transition
	always@(*)begin
		case(state)
		
			init     :  next_state = (write == 1'b1) ? decode : init;
			decode   :  begin
								case(write_value)begin
									code_wren  : next_state = wren;
									code_write : next_state = write;
									code_read  : next_state = read;
									
									default: next_state = idle;
								endcase
							end
			wren		:	next_state = (write_complete) ? init : wren; 
			read     :	next_state = (write_complete) ? init : read;
			write    :	next_state = (write_complete) ? init : write;
			
			default  : 	next_state = init;
			
		endcase
	end
	
	//Execute
	
	wire wren_sck,wren_write_complete,wren_spi_do;
	wire read_sck,read_write_complete,read_spi_do;
	wire write_sck,write_write_complete,write_spi_do;
	
	always@(*)begin
		case(state)
			init		:	begin
								spi_csn  = 1'b1;
								spi_sck  = 1'b0;
								spi_do   = 1'b0;
								write_complete = 1'b1;
							end
			decode	:	begin
								spi_csn  = 1'b1;
								spi_sck  = 1'b0;
								spi_do   = 1'b0;
								write_complete = 1'b0;
							end
			wren		:	begin
								spi_csn  = 1'b0;
								spi_sck  = ;
								spi_do   = ;
								write_complete = ;
							end
			read		:	begin
								spi_csn  = 1'b0;
								spi_sck  = ;
								spi_do   = ;
								write_complete = ;
							end
			write		:	begin
								spi_csn  = 1'b0;
								spi_sck  = write_sck;
								spi_do   = write_spi_do;
								write_complete = write_write_complete;
							end
			default	:	begin
								spi_csn  = 1'b1;
								spi_sck  = ;
								spi_do   = ;
								write_complete = ;
							end
		endcase
	end
	
	write write_module(
		//System
		.clk(clk_50M),
		.reset_n(reset_n),
		
		//Controls & Datas
		.en(state == write),
		.write(write),
		.data(write_value),
		
		//Signal out
		.write_complete(write_write_complete),
		.sck(write_sck),
		.spi_do(write_spi_do)
	);
	
	

endmodule
