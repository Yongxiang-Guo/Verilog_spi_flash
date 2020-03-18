`timescale 1ns/1ps
////////////////////////////////////////////
//Module Name	:	flash
//Description	:	top_file
//Editor		:	Yongxiang
//Time			:	2020-02-03
////////////////////////////////////////////
module flash
	(
		input	wire	CLK,
		input	wire	RSTn,
		
		output	wire	flash_clk,		//spi flash clock 
		output	wire	flash_cs,		//spi flash cs 
		output	wire	flash_datain,	//spi flash data input  
		input	wire	flash_dataout	//spi flash data output
	);

wire[7:0] flash_cmd;
wire[23:0] flash_addr;
wire clock25M;
wire[3:0] cmd_type;
wire Done_Sig;
wire[7:0] mydata_o;
wire myvalid_o;

//spi通信
spi spi_inst
	(
		.flash_clk(flash_clk),
		.flash_cs(flash_cs),
		.flash_datain(flash_datain),  
		.flash_dataout(flash_dataout),    
		
		.clock25M(clock25M),		//input clock
		.flash_rstn(RSTn),		//input reset 
		.cmd_type(cmd_type),		// flash command type		  
		.Done_Sig(Done_Sig),		//output done signal
		.flash_cmd(flash_cmd),	// input flash command 
		.flash_addr(flash_addr),// input flash address 
		.mydata_o(mydata_o),		// output flash data 
		.myvalid_o(myvalid_o)	// output flash data valid 		
	);

//flash控制
flash_control flash_control_inst
(
   .CLK(CLK),
	.RSTn(RSTn),
	.clock25M(clock25M),
	.cmd_type(cmd_type),
	.Done_Sig(Done_Sig),
	.flash_cmd(flash_cmd),
	.flash_addr(flash_addr),
	.mydata_o(mydata_o),
	.myvalid_o(myvalid_o)
);

endmodule
