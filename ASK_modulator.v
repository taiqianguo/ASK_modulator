

module single_port_rom
#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=8)//data width == DAC output width 
(															//for 1Mhz carrier frequency accuracy we only use 0-199 address.
	input [(ADDR_WIDTH-1):0] addr,
	input clk, 
	output reg [(DATA_WIDTH-1):0] q
);

	// Declare the ROM variable
	reg [DATA_WIDTH-1:0] rom[2**ADDR_WIDTH-1:0];

	initial
	begin
		$readmemb("../db/sin.txt", rom);
	end

	always @ (posedge clk)
	begin
		q <= rom[addr];
	end

endmodule


module DDS(
	input wire clk,
	input wire rst,
	input wire [7:0] M, // output frequency= 50Mhz/200* M, based on nyquist sample, M should not succeed 100.
	                   // when M=4 , output freqency =1Mhz
	output wire [7:0]sin_out);
   
	reg [7:0]addr_counter; // this is the address of the rom LUT
	
	always@(posedge clk )
	begin
		if(! rst) addr_counter<=0;
		else if (addr_counter>=200)
		addr_counter<=0;
		else 
		addr_counter<=addr_counter+M;
	end	
	
	single_port_rom LUT(
	.addr(addr_counter),
	.clk(clk),
	.q(sin_out));// here's the DDS frequency output 
	
endmodule


module RandomNumberGenerator(
    output reg [3:0] random_number, // 4-bit random number output
    input wire clk,                // Clock input 10
    input wire rst                 // Synchronous reset input
);
reg [31:0]long_random=32'hACE1;
// Internal signal for feedback bit
wire feedback;

// Feedback
assign feedback = (long_random[31] ^ long_random[21]^ long_random[1]^ long_random[0]);

// Sequential logic for the LFSR with synchronous reset
always @(posedge clk) begin
    if (! rst) begin
        long_random=32'hACE1; // Non-zero initial value
    end else begin
        // Shift left by 1 bit and insert feedback into LSB
        long_random <= {long_random[30:0], feedback};
		  random_number<=long_random[3:0];
    end
end

endmodule


module data_converter ( //generate 10Kbit/s throughput and encode it to parallel and mudulate.
	input wire [1:0]mixer_mode,//00 for stop mixer, 01 for 2ASK, 10 for 4ASK, 11 for 8ASK
	input wire data_in, //one bit data input
	input wire clk,
	input wire rst,
	input wire [7:0]sin_in,
	output reg [15:0]dac_data
	);
	
	reg  [2:0]parallel_data=0;
	reg  temp1_data=0;
	reg  temp2_data=0; //the temp data for the parallel data
	reg [15:0]counter=0;// the counter for 10kbit/s data
	
	always @(posedge clk )
	if(! rst) counter<=0;
	else
	case(mixer_mode)
		2'b00,
		2'b01:begin
					if(counter==5000)
						begin
							counter<=0;
							parallel_data[0]<=data_in;
							parallel_data[2:1]<=2'b00;
						end
					else	
						begin 
							counter<=counter+1;
							parallel_data<=parallel_data;
						end
				end
		2'b10:begin
					if(counter==10000)
						begin
							counter<=0;
							parallel_data[0]<=data_in;
							parallel_data[1]<=temp1_data;
							parallel_data[2]<=0;
							temp1_data<=0;
						end
					else if(counter==5000)
						begin
							temp1_data<=data_in;
							counter<=counter+1;
							parallel_data<=parallel_data;
						end
					else 
						begin
							counter<=counter+1;
							parallel_data<=parallel_data;
						end
				end
		2'b11:begin
					if (counter==15000)
						begin
							counter<=0;
							parallel_data[0]<=data_in;
							parallel_data[1]<=temp1_data;
							parallel_data[2]<=temp2_data;
							temp1_data<=0;
							temp2_data<=0;
						end
					else if(counter==10000)
						begin
							temp1_data<=data_in;
							counter<=counter+1;
							parallel_data<=parallel_data;
						end
					else if(counter==5000)
						begin
							temp2_data<=data_in;
							counter<=counter+1;
							parallel_data<=parallel_data;
						end
					else 
						begin
							counter<=counter+1;
							parallel_data<=parallel_data;
						end
				end
	endcase			
				
	always @(posedge clk)
		case(mixer_mode)
			2'b00:dac_data<=0;
			2'b01:dac_data<=sin_in*parallel_data[0];
			2'b10:dac_data<=(sin_in >> 1)*parallel_data[1:0];
			2'b11:dac_data<=(sin_in >> 2)*parallel_data;
		endcase
endmodule				
				
module ASK_modulator(
	input wire clk,
	input wire rst,
	input wire button0,// 
	input wire button1,//after reset , press button twice to determine the mixer_mode
	output wire  clk_dac,
	output reg [7:0]data_out	);	
	
	assign clk_dac=clk;
	
   wire serials_data;
	wire [3:0]random_data;
	assign serials_data=random_data[0];
	
	RandomNumberGenerator rg0(
	.clk(clk),
	.random_number(random_data),
	.rst(rst)); 
   
	wire [7:0]sin;
	
	DDS dds0(
	.clk(clk),
	.rst(rst),
	.M(8'b00000100),
	.sin_out(sin)
	);
	
	reg [1:0]mode=0	;
	reg [1:0]press_state;//a simpel state machine, 0 indicate no transfer 
	reg [3:0]temp_button0;
	reg [3:0]temp_button1;
	
	always@(posedge clk) //button press sync  module and prevent unstable shaking
	begin	
		temp_button0<={temp_button0[2:0],button0};
		temp_button1<={temp_button1[2:0],button1};
		if (! rst)
			begin
				mode<=0;
				press_state<=0;
			end
			
		else if(press_state==0)
		  if(! temp_button0[3] & temp_button0[2])// button0 posedge trigger
			begin	
				mode[0]=0;
				press_state<=1;
			end
		  else if(! temp_button1[3] & temp_button1[2])// button1 posedge trigger
			begin	
				mode[0]=1;
				press_state<=1;
			end
		  else 
			begin
				press_state<=press_state;
				mode<=mode;
			end
			
		else if(press_state==1)
		  if(! temp_button0[3] & temp_button0[2])// button0 posedge trigger
				begin	
					mode[1]=0;
					press_state<=2;
				end
		  else if(! temp_button1[3] & temp_button1[2])// button1 posedge trigger
				begin	
					mode[1]=1;
					press_state<=2;
				end
		  else 
				begin
					press_state<=press_state;
					mode<=mode;
				end	
	
		else 
			begin
				press_state<=press_state;
				mode<=mode;
			end	
	end			
	
	reg [1:0]mode_out;
	
	
	always @( posedge clk) // this  prevent intermediate value of mode
		begin
		if (! rst)
			mode_out<=0;
		else if (press_state==2)
			mode_out<=mode;
		else
			mode_out<=mode_out;
		end	
	
	
	wire [15:0]data_5v;
	data_converter dc0(
	.clk(clk),
	.rst(rst),
	.data_in(serials_data),
	.sin_in(sin),
	.mixer_mode(mode_out),
	.dac_data(data_5v)
	);
	
	always @(posedge clk)
	data_out<=(data_5v /5)*2;// here attenuated output from 5V to 2V
endmodule
	
	
	
	
	
	
