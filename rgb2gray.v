//***************************************
//COPYRIGHT(C)2025,EthasuLi
//All rights reserved.
//Module Name  : rgb2gray.v
//
//Author       : EthasuLi
//Email        : 13591028146@163.com
//Data         : 2025/8/5
//Version      : V 1.0
//
//Abstract     : 
//Called by    :
//
//****************************************  
module rgb2gray
(
	input 					clk		,
	input 					rst_n	,
	input		[7:0]		r		,
	input		[7:0]		g		,
	input		[7:0]		b		,
	input					vsync	,
	input					hsync	,
	input					de		,
	
	output 					gray_v	,
	output 					gray_h	,
	output 					gray_de	,
	output 	reg	[7:0]		gray	,
	output  reg [23:0]		rgb
);
reg [8:0] rg_gray;
reg [9:0] sum_gray;
reg [2:0] v_shift;
reg [2:0] h_shift;
reg [2:0] de_shift;
reg [23:0] rgb_d0;
reg [23:0] rgb_d1;
reg [7:0] b_d;
always@(posedge clk) begin
	b_d <= b;
end
always@(posedge clk or negedge rst_n) begin
	if(~rst_n)
		rg_gray <= 'd0;
	else
		rg_gray <= r + g;
end
always@(posedge clk or negedge rst_n) begin
	if(~rst_n)
		sum_gray <= 'd0;
	else
		sum_gray <= rg_gray + b_d;
end

always@(posedge clk or negedge rst_n) begin
	if(~rst_n)
		gray <= 'd0;
	else
		gray <= sum_gray /3;
end
// 3拍
always@(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		v_shift		<= 'd0;
		h_shift     <= 'd0;
		de_shift    <= 'd0;
	end
	else begin
		v_shift		<= {v_shift[1:0]	,vsync};
		h_shift     <= {h_shift[1:0] ,hsync};
		de_shift    <= {de_shift[1:0],de};
	end
end
assign gray_v 	= v_shift[2];
assign gray_h 	= h_shift[2];
assign gray_de  = de_shift[2];

always@(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		rgb_d0 <= 'd0;
		rgb_d1 <= 'd0;
		rgb    <= 'd0;
	end	
	else begin
		rgb_d0 <= {r,g,b};
		rgb_d1 <= rgb_d0;
		rgb    <= rgb_d1;
	end
end


endmodule

