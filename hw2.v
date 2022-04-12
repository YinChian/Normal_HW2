`define code_wren  8'h06
`define code_write 8'h02
`define code_read  8'h03

`define sck_counter_max 11'd2_000
`define sck_counter_half 11'd1_000


module hw2(
	//System0
	input  clk_50M,
	input  reset_n,
	
	//Control
	input  write,
	input  read,
	
	//State
	output reg write_complete,
	output read_complete,
	
	//Data
	input  [7:0] write_value,		//write value ---process---> DO
	output reg [7:0] read_value,	//read value  <---process--- SI
											//only exsists while reading
	
	//Signals
	output reg spi_csn,				//-CS--// Chip Select
	output reg spi_sck,				//-SCK-// clock
	output reg spi_do,				//-SI--// slave in
	input  spi_di						//-DO--// slave out
	
	
);
	
	
	//Parameter
	
	parameter init = 0, decode = 1, wren = 2, reading = 3, writing = 4;
	reg [2:0] state, next_state;
	
	
	//Passing
	
	always@(posedge clk_50M,negedge reset_n)begin
		if(!reset_n) state <= 2'b0;
		else state <= next_state; 
	end
	
	
	//Transition
	
	wire read_done, write_done;
	always@(*)begin
		case(state)
		
			init     :  next_state = (write == 1'b1) ? decode : init;
			decode   :  begin
								case(write_value)
									`code_wren  : next_state = wren;
									`code_write : next_state = writing;
									`code_read  : next_state = reading;
									
									default: next_state = init;
								endcase
							end
			wren		:	next_state = (write_complete == 1'b1) ? init : wren; 
			reading  :	next_state = (read_done == 1'b1) ? init : reading;
			writing  :	next_state = (write_done == 1'b1) ? init : writing;
			
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
								spi_sck  = wren_sck;
								spi_do   = wren_spi_do;
								write_complete = wren_write_complete;
							end
			reading	:	begin
								spi_csn  = 1'b0;
								spi_sck  = read_sck;
								spi_do   = read_spi_do;
								write_complete = read_write_complete;
							end
			writing	:	begin
								spi_csn  = 1'b0;
								spi_sck  = write_sck;
								spi_do   = write_spi_do;
								write_complete = write_write_complete;
							end
			default	:	begin
								spi_csn  = 1'b1;
								spi_sck  = 1'b0;
								spi_do   = 1'b0;
								write_complete = 1'b0;
							end
		endcase
	end
	
	//Output Latch
	
	wire [7:0] output_buffer;
	always@(posedge clk_50M,negedge reset_n)begin
		if(!reset_n) read_value <= 8'd0;
		else if(read_complete) read_value <= output_buffer;
		else read_value <= read_value;
	end
	
	//Extrnal Modules
	
	wire write_en, send_en, read_en;
	assign write_en = state == writing;
	assign send_en = state == wren;
	assign read_en = state == reading;
	
	writer write_module(
		//System
		.clk(clk_50M),
		.reset_n(reset_n),
		
		//Controls & Datas
		.en(write_en),
		.write(write),
		.data(write_value),
		
		//Signal out
		.write_complete(write_write_complete),
		.sck(write_sck),
		.spi_do(write_spi_do),
		
		
		.total_done(write_done)
	);
	
	send_cmd command_send_module(
		//System
		.clk(clk_50M),
		.reset_n(reset_n),
		
		//Controls & Datas
		.en(send_en),
		.write(write),
		.data(write_value),
		
		//Signal out
		.write_complete(wren_write_complete),
		.sck(wren_sck),
		.spi_do(wren_spi_do),
		
	);
	
	reader read_module(
		//System
		.clk(clk_50M),
		.reset_n(reset_n),
		
		//Controls & Datas
		.en(read_en),
		.write(write),
		.data(write_value),
		.read(read),
		
		//Signal out
		.write_complete(read_write_complete),
		.sck(read_sck),
		.spi_do(read_spi_do),
		
		//Retrive data
		.spi_di(spi_di),
		.read_data(output_buffer),
		.read_complete(read_complete),
		
		
		.total_done(read_done)
		
	);
	

endmodule
