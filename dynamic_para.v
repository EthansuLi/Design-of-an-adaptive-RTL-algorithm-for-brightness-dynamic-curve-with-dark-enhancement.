//***************************************
//COPYRIGHT(C)2025,EthasuLi
//All rights reserved.
//Module Name  : dynamic_para.v
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
module dynamic_para#(
	parameter QVAL 		= 255	,
	parameter LREF_Q 	= 154	,
	parameter SHIFT 	= 8		,
	parameter K_Q 		= 587	,
	parameter PMAX_Q 	= 587	,
	parameter ALPHA_H_Q = 561	,
	parameter LB_Q 		= 51	,
	parameter K2_Q		= 2040	,
	parameter SMOOTH_K	= 5
)(
	input 						clk			 	,
	input 						rst_n		 	,
	input		[23:0]			rgb			 	,
	input		[7:0]			gray		 	,
	input						vsync		 	,
	input						hsync		 	,
	input						de			 	,
				
	output 						o_v			 	,
	output 						o_h			 	,
	output 						o_de		 	,
	output  	[23:0]			o_rgb		 	,
	output  reg [15:0] 			p_q				,
	output 	reg	[7:0]			p2_q
);
parameter  H = 1080;
parameter  W = 1920;

reg vsync_d0;
wire vsync_fall;
always@(posedge clk) begin
	vsync_d0 <= vsync;
end
assign vsync_fall = !vsync && vsync_d0;

reg  [15:0] Lmean; // Q8.8;
reg  [15:0] diff1;
reg  [25:0] mut_diff1;
reg  [17:0] dp_q; 

reg  [15:0] diff2;
reg  [26:0] mut_diff2;
reg  [18:0] dp2_q; 

reg [4:0] shift_vs;
reg [4:0] shift_hs;
reg [4:0] shift_de;
reg [119:0] shift_rgb;
// Q8.8
always@(posedge clk or negedge rst_n) begin // 1æ‹?
	if(~rst_n)
		Lmean <= LREF_Q;
	else if(vsync_fall)
		Lmean <= LREF_Q;
	else if(de) begin
			if(gray >= Lmean)
				Lmean <= Lmean + ((gray - Lmean)>>>SMOOTH_K);
			else
				Lmean <= Lmean - ((Lmean - gray)>>>SMOOTH_K);
	end
end
// 3æ‹?
always@(posedge clk or negedge rst_n) begin 
	if(~rst_n) begin
		diff1 <= 'd0;
		mut_diff1 <= 'd0;
		dp_q <= 'd0;
	end
	else begin	
		if(LREF_Q >= Lmean) begin
			diff1 <= LREF_Q - Lmean;
			mut_diff1 <= K_Q*diff1;
			dp_q <= mut_diff1 >> SHIFT;
		end
		else begin
			diff1 <= 'd0;
			mut_diff1 <= 'd0;
			dp_q <= 'd0;
		end
	end
end

always@(posedge clk or negedge rst_n) begin 
	if(~rst_n) begin
		diff2 <= 'd0;
		mut_diff2 <= 'd0;
		dp2_q <= 'd0;
	end
	else begin	
		if(Lmean > LB_Q) begin
			diff2 <= Lmean - LB_Q;
			mut_diff2 <= K2_Q*diff2;
			dp2_q <= mut_diff2 >> SHIFT;
		end
		else begin
			diff2 <= 'd0;
			mut_diff2 <= 'd0;
			dp2_q <= 'd0;
		end
	end
end

// 1æ‹?
always@(posedge clk or negedge rst_n) begin 
	if(~rst_n)
		p_q <= 'd0;
	else begin
		if(dp_q == 0)
			p_q <= 'd0;
		else if(dp_q[15:0] > PMAX_Q)
			p_q <= PMAX_Q;
		else
			p_q <= dp_q[15:0];
	end
end

always@(posedge clk or negedge rst_n) begin 
	if(~rst_n)
		p2_q <= 'd0;
	else begin
		if(dp2_q[13:6] <= QVAL)
			p2_q <= dp2_q[13:6];
		else
			p2_q <= QVAL;
	end
end

// ä¸?å…±æ‰“5æ‹?
always@(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		shift_vs	<= 'd0;
		shift_hs   	<= 'd0;
		shift_de   	<= 'd0;
		shift_rgb	<= 'd0;
	end
	else begin
		shift_vs	 <= {shift_vs[3:0]	, vsync};
		shift_hs     <= {shift_hs[3:0]  , hsync};
		shift_de     <= {shift_de[3:0]  , de};
		shift_rgb	 <= {shift_rgb[95:0],rgb};
	end
end
assign o_v		= shift_vs[4];
assign o_h		= shift_hs[4];
assign o_de 	= shift_de[4];
assign o_rgb	= shift_rgb[119:96];


endmodule

