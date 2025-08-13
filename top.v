//***************************************
//COPYRIGHT(C)2025,EthasuLi
//All rights reserved.
//Module Name  : c_tab.v
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
module top
(
	input 						clk			 	,
	input 						rst_n		 	,
	
	input 						i_vs		 	,
	input 						i_hs		 	,
	input 						i_de		 	,
	input  		[23:0]			i_rgb		 	,

	output						o_vs			,
	output						o_hs			,
	output						o_de			,
	output		[23:0]			o_rgb			,
	output		[23:0]			o_src_rgb	
);
	parameter QVAL 		= 8'd255	;
	parameter LREF_Q 	= 88	;
	parameter SHIFT 	= 8		;
	parameter K_Q 		= 587	;
	parameter PMAX_Q 	= 587	;
	parameter ALPHA_H_Q = 561	;
	parameter LB_Q 		= 26	;
	parameter K2_Q		= 2040	;
	parameter SMOOTH_K	= 0     ;



wire [7:0]		gray;
wire [23:0]		gray_rgb;
wire gray_v	  ;
wire gray_h	  ;
wire gray_de  ;

wire		dynamic_para_v	  ;
wire		dynamic_para_h	  ;
wire		dynamic_para_de   ;
wire	[23:0]	dynamic_para_rgb  ;
wire [15:0] p_q;
wire [7:0] p2_q;

// rgb打22 拍
reg [527:0] shift_rgb;
always@(posedge clk or negedge rst_n) begin
	if(~rst_n)
		shift_rgb <= 'd0;
	else
		shift_rgb <= {shift_rgb[503:0],i_rgb};
end
assign o_src_rgb = shift_rgb[527:504];

rgb2gray inst_rgb2gray // 3拍
(
	.clk		(clk),
	.rst_n	(rst_n),
	.r		(i_rgb[23:16]),
	.g		(i_rgb[15:8]),
	.b		(i_rgb[7:0]),
	.vsync	(i_vs),
	.hsync	(i_hs),
	.de		(i_de),
	.gray_v	(gray_v	),
	.gray_h	(gray_h	),
	.gray_de(gray_de),
	.gray	(gray	),
	.rgb    (gray_rgb    )
);

dynamic_para#(					// 5拍
	.QVAL 		(QVAL 		),
	.LREF_Q 	(LREF_Q 	),
	.SHIFT 		(SHIFT 		),
	.K_Q 		(K_Q 		),
	.PMAX_Q 	(PMAX_Q 	),
	.ALPHA_H_Q 	(ALPHA_H_Q  ),
	.LB_Q 		(LB_Q 		),
	.K2_Q		(K2_Q		),
	.SMOOTH_K	(SMOOTH_K	)
) inst_dynamic_para(
	.clk			(clk),
	.rst_n		 	(rst_n),
	.rgb			(gray_rgb),
	.gray		 	(gray),
	.vsync		 	(gray_v),
	.hsync		 	(gray_h),
	.de			 	(gray_de),
	.o_v			(dynamic_para_v		),
	.o_h			(dynamic_para_h		),
	.o_de		 	(dynamic_para_de	),
	.o_rgb		 	(dynamic_para_rgb	),
	.p_q			(p_q	),
	.p2_q           (p2_q   )
);

 main_map	// 14拍
#(
	.QVAL 	(QVAL ),
	.SHIFT 	(SHIFT),
	.ALPHA_H_Q(ALPHA_H_Q)
) main_map_inst(
	.clk			(clk),
	.rst_n		 	(rst_n),
	.i_vs		 	(dynamic_para_v),
	.i_hs		 	(dynamic_para_h),
	.i_de		 	(dynamic_para_de),
	.i_rgb		 	(dynamic_para_rgb),
	.p_q			(p_q), 
	.p2_q			(p2_q),
	.o_vs			(o_vs	),
	.o_hs			(o_hs	),
	.o_de			(o_de	),
	.o_rgb          (o_rgb)
);
endmodule

