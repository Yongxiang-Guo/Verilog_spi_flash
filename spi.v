`timescale 1ns/1ps
////////////////////////////////////////////
//Module Name	:	spi
//Description	:	spi communication module
//Editor			:	Yongxiang
//Time			:	2020-02-03
////////////////////////////////////////////
module spi
	(
		output	wire	flash_clk,
		output 	reg	flash_cs,
		output	reg	flash_datain,
		input		wire	flash_dataout,
		
      input		wire	clock25M,
		input		wire	flash_rstn,
		input		wire[3:0]	cmd_type,
		output	reg	Done_Sig,
		input		wire[7:0]	flash_cmd,
		input		wire[23:0]	flash_addr,
		output 	reg[7:0]		mydata_o,
		output	wire	myvalid_o
	);

assign myvalid_o = myvalid;
assign flash_clk = spi_clk_en ? clock25M : 1'b0;

reg myvalid;
reg[7:0] mydata;
reg spi_clk_en = 1'b0;
reg data_come;

parameter idle = 3'b000;
parameter cmd_send = 3'b001;
parameter address_send = 3'b010;
parameter read_wait = 3'b011;
parameter write_data = 3'b101;
parameter finish_done = 3'b110;

reg[2:0] spi_state;
reg[7:0] cmd_reg;
reg[23:0] address_reg;
reg[7:0] cnta;
reg[8:0] write_cnt;
reg[7:0] cntb;
reg[8:0] read_cnt;
reg[8:0] read_num;
reg read_finish;

//发送读flash命令
always @(negedge clock25M)
begin
	if(!flash_rstn)begin
		flash_cs <= 1'b1;		
		spi_state <= idle;
		cmd_reg <= 8'd0;
		address_reg <= 24'd0;
	   spi_clk_en <= 1'b0;		//SPI clock输出不使能
		cnta <= 8'd0;
		write_cnt <= 9'd0;
		read_num <= 9'd0;	
		Done_Sig <= 1'b0;
	end
	else begin
		case(spi_state)
			idle:begin	//idle 状态		  
				spi_clk_en <= 1'b0;
				flash_cs <= 1'b1;
				flash_datain <= 1'b1;	
			   cmd_reg <= flash_cmd;
            address_reg <= flash_addr;
		      Done_Sig <= 1'b0;				
				if(cmd_type[3] == 1'b1)begin	//bit3为命令请求,高表示操作命令请求
					spi_state <= cmd_send;
					cnta <= 8'd7;		
					write_cnt <= 9'd0;
					read_num <= 9'd0;					
				end
			end
			
			cmd_send:begin	//发送命令状态	
			   spi_clk_en <= 1'b1;	//flash的SPI clock输出
				flash_cs <= 1'b0;	//cs拉低
			   if(cnta > 8'd0)begin	//如果cmd_reg还没有发送完
					flash_datain <= cmd_reg[cnta];	//发送bit7~bit1位
               cnta <= cnta - 8'd1;
				end
				else begin	//发送bit0
					flash_datain <= cmd_reg[0];
					if((cmd_type[2:0] == 3'b001) | (cmd_type[2:0] == 3'b100))begin	//如果是Write Enable/disable instruction
						spi_state <= finish_done;
					end						 
					else if(cmd_type[2:0] == 3'b011)begin	//如果是read register1
						spi_state <= read_wait;
						cnta <= 8'd7;
						read_num <= 9'd1;	//接收一个数据
					end	 
					else begin	//如果是sector erase, page program, read data,read device ID      
						spi_state <= address_send;
						cnta <= 8'd23;
					end
				end
			end
			
			address_send:begin	//发送flash address	
			   if(cnta > 8'd0)begin	//如果cmd_reg还没有发送完
					flash_datain <= address_reg[cnta];	//发送bit23~bit1位
               cnta <= cnta - 8'd1;						
				end				
				else begin	//发送bit0
					flash_datain <= address_reg[0];   
               if(cmd_type[2:0] == 3'b010)begin	//如果是	sector erase
 						spi_state <= finish_done;	
               end
               else if(cmd_type[2:0] == 3'b101)begin	//如果是page program				
				      spi_state <= write_data;
						cnta <= 8'd7;                       
					end
					else if(cmd_type[2:0] == 3'b000)begin	//如果是读Device ID
					   spi_state <= read_wait;
						read_num <= 9'd2;		//接收2个数据的Device ID
               end						 
					else begin
					   spi_state <= read_wait;
						read_num <= 9'd256;	//如果是block读命令,接收256个数据							 
               end						 
				end
			end
			
			read_wait:begin	//等待flash数据读完成
				if(read_finish)begin
					spi_state <= finish_done;
					data_come <= 1'b0;
				end
				else begin
					data_come <= 1'b1;
				end
			end
			
			write_data:begin	//写flash block数据
				if(write_cnt < 9'd256)begin	// program 256 byte to flash
					if(cnta > 8'd0)begin	//如果data还没有发送完
						flash_datain <= write_cnt[cnta];	//发送bit7~bit1位
                  cnta <= cnta - 8'd1;						
					end				
					else begin                                 
						flash_datain <= write_cnt[0];	//发送bit0
					   cnta <= 8'd7;
					   write_cnt <= write_cnt + 9'd1;
					end
				end
				else begin
					spi_state <= finish_done;
					spi_clk_en <= 1'b0;
				end 
			end
			
			finish_done:begin	//flash操作完成
				flash_cs <= 1'b1;
				flash_datain <= 1'b1;
				spi_clk_en <= 1'b0;
				Done_Sig <= 1'b1;
				spi_state <= idle;
			end
			
			default:begin
				spi_state <= idle;
			end
			
		endcase;		
	end
end
	
//接收flash数据	
always @(posedge clock25M)
begin
	if(!flash_rstn)begin
		read_cnt <= 9'd0;
		cntb <= 8'd0;
		read_finish <= 1'b0;
		myvalid <= 1'b0;
		mydata <= 8'd0;
		mydata_o <= 8'd0;
	end
	else begin
		if(data_come)begin
			if(read_cnt < read_num)begin	//接收数据			  
				if(cntb < 8'd7)begin	//接收一个byte的bit0~bit6		  
					myvalid <= 1'b0;
					mydata <= {mydata[6:0], flash_dataout};
					cntb <= cntb + 8'd1;
				end
				else begin
					myvalid <= 1'b1;	//一个byte数据有效
					mydata_o <= {mydata[6:0], flash_dataout};	//接收bit7
					cntb <= 8'd0;
					read_cnt <= read_cnt + 9'd1;
				end
			end				 			 
			else begin 
				read_cnt <= 9'd0;
				read_finish <= 1'b1;
				myvalid <= 1'b0;
			end
		end
		else begin
			read_cnt <= 9'd0;
			cntb <= 8'd0;
			read_finish <= 1'b0;
			myvalid <= 1'b0;
			mydata <= 8'd0;
		 end
	end
end	

endmodule
