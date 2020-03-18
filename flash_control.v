`timescale 1ns/1ps
////////////////////////////////////////////
//Module Name	:	flash_control
//Description	:	flash read and write control
//Editor			:	Yongxiang
//Time			:	2020-02-03
////////////////////////////////////////////
module flash_control
	(
		input		wire	CLK,
		input		wire	RSTn,
		output	reg	clock25M,
		output	reg[3:0]	cmd_type,
		input		wire	Done_Sig,
		output	reg[7:0]	flash_cmd,
		output	reg[23:0]	flash_addr,
		input		wire[7:0]	mydata_o,
		input		wire	myvalid_o
	);
 
reg[3:0] i;
reg[7:0] time_delay;

//FLASH 擦除,Page Program,读取程序	
always @(posedge clock25M)
begin
   if(!RSTn)begin
		i <= 4'd0;
		flash_addr <= 24'd0;
		flash_cmd <= 8'd0;
		cmd_type <= 4'b0000;
		time_delay <= 8'd0;
	end
	else begin
	   case(i)
			4'd0:begin	//读Device ID
				if( Done_Sig )begin
					flash_cmd <= 8'h00;
					i <= i + 4'd1;
					cmd_type <= 4'b0000;
				end
				else begin
					flash_cmd <= 8'h90;
					flash_addr <= 24'd0;
					cmd_type <= 4'b1000;
				end	
			end
			
	      4'd1:begin	//写Write Enable instruction
				if(Done_Sig)begin
					flash_cmd <= 8'h00;
					i <= i + 4'd1;
					cmd_type <= 4'b0000;
				end
				else begin
					flash_cmd <= 8'h06;
					cmd_type <= 4'b1001;
				end
			end
			
			4'd2:begin	//Sector擦除
				if(Done_Sig)begin
					flash_cmd <= 8'h00;
					i <= i + 4'd1;
					cmd_type<=4'b0000;
				end
				else begin
					flash_cmd <= 8'h20;
					flash_addr <= 24'd0;
					cmd_type <= 4'b1010;
				end
			end
			
	      4'd3:begin	//waitting 100 clock
				if(time_delay < 8'd100)begin
					flash_cmd <= 8'h00;
					time_delay <= time_delay + 8'd1;
					cmd_type <= 4'b0000;
				end
				else begin
					i <= i + 4'd1;
					time_delay <= 8'd0;
				end	
			end
			
			4'd4:begin	//读状态寄存器1, 等待idle
				if(Done_Sig)begin 
					if(mydata_o[0] == 1'b0)begin
						flash_cmd <= 8'h00;
						i <= i + 4'd1;
						cmd_type <= 4'b0000;
					end
					else begin
						flash_cmd <= 8'h05;
						cmd_type <= 4'b1011;
					end
				end
				else begin
					flash_cmd <= 8'h05;
					cmd_type <= 4'b1011;
				end
			end
			
	      4'd5:begin	//写Write disable instruction
				if(Done_Sig)begin
					flash_cmd <= 8'h00;
					i <= i + 4'd1;
					cmd_type <= 4'b0000;
				end
				else begin
					flash_cmd <= 8'h04;
					cmd_type <= 4'b1100;
				end
			end
			
			4'd6:begin	//读状态寄存器1, 等待idle
				if(Done_Sig)begin
					if(mydata_o[0] == 1'b0)begin
						flash_cmd <= 8'h00;
						i <= i + 4'd1;
						cmd_type <= 4'b0000;
					end
					else begin
						flash_cmd <= 8'h05;
						cmd_type <= 4'b1011;
					end
				end
				else begin
					flash_cmd <= 8'h05;
					cmd_type <= 4'b1011;
				end
			end
			
	      4'd7:begin	//写Write Enable instruction
				if(Done_Sig)begin
					flash_cmd <= 8'h00;
					i <= i + 4'd1;
					cmd_type <= 4'b0000;
				end
				else begin
					flash_cmd <= 8'h06;
					cmd_type <= 4'b1001;
				end 
			end
			
	      4'd8:begin	//waitting 100 clock
				if(time_delay < 8'd100)begin
					flash_cmd <= 8'h00;
					time_delay <= time_delay + 8'd1;
					cmd_type <= 4'b0000;
				end
				else begin
					i <= i + 4'd1;
					time_delay <= 8'd0;
				end	
			end
			
	      4'd9:begin	//page program: write 0~255 to flash
				if(Done_Sig)begin
					flash_cmd <= 8'h00;
					i <= i + 4'd1;
					cmd_type <= 4'b0000;
				end
				else begin
					flash_cmd <= 8'h02;
					flash_addr <= 24'd0;
					cmd_type <= 4'b1101;
				end
			end
			
	      4'd10:begin	//waitting
				if(time_delay < 8'd100)begin
					flash_cmd <= 8'h00;
					time_delay <= time_delay + 8'd1;
					cmd_type <= 4'b0000;
				end
				else begin
					i <= i + 4'd1;
					time_delay <= 8'd0;
				end	
			end
			
			4'd11:begin	//读状态寄存器1, 等待idle
				if(Done_Sig)begin 
					if(mydata_o[0] == 1'b0)begin
						flash_cmd <= 8'h00;
						i <= i + 4'd1;
						cmd_type <= 4'b0000;
					end
					else begin
						flash_cmd <= 8'h05;
						cmd_type <= 4'b1011;
					end
				end
				else begin
					flash_cmd <= 8'h05;
					cmd_type <= 4'b1011;
				end
			end
			
	      4'd12:begin	//写Write disable instruction
				if(Done_Sig)begin
					flash_cmd <= 8'h00;
					i <= i + 4'd1;
					cmd_type <= 4'b0000;
				end
				else begin
					flash_cmd <= 8'h04;
					cmd_type <= 4'b1100;
				end		
			end
			
			4'd13:begin	//读状态寄存器1, 等待idle
				if(Done_Sig)begin
					if(mydata_o[0] == 1'b0)begin
						flash_cmd <= 8'h00;
						i <= i + 4'd1;
						cmd_type <= 4'b0000;
					end
					else begin
						flash_cmd <= 8'h05;
						cmd_type <= 4'b1011;
					end
				end
				else begin
					flash_cmd <= 8'h05;
					cmd_type <= 4'b1011;
				end
			end
			
			4'd14:begin	//read 256byte
				if(Done_Sig)begin
					flash_cmd <= 8'h00;
					i <= i + 4'd1;
					cmd_type <= 4'b0000;
				end
				else begin
					flash_cmd <= 8'h03;
					flash_addr <= 24'd0;
					cmd_type <= 4'b1110;
				end
			end
			
			4'd15:begin	//idle
				i <= 4'd15;
			end
			
		endcase
	end
end


//产生25Mhz的SPI Clock		  
always @(posedge CLK)
begin
   if(!RSTn)begin
		clock25M <= 1'b0;
	end
	else begin
		clock25M <= ~clock25M;
	end
end

endmodule
