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
module main_map
#(
	parameter QVAL 		= 255	,
	parameter SHIFT 	= 8		,
	parameter ALPHA_H_Q = 561	
)(
	input 						clk			 	,
	input 						rst_n		 	,
	
	input 						i_vs		 	,
	input 						i_hs		 	,
	input 						i_de		 	,
	input  		[23:0]			i_rgb		 	,
	input   	[15:0] 			p_q				, //Q8.8
	input  		[7:0]			p2_q			,

	output						o_vs			,
	output						o_hs			,
	output						o_de			,
	output		[23:0]			o_rgb			

);

wire [7:0] r,g,b;
assign r = i_rgb[23:16];
assign g = i_rgb[15:8];
assign b = i_rgb[7:0];

wire [7:0] r_ctab;
wire [7:0] g_ctab;
wire [7:0] b_ctab;
wire [7:0] oneXr;
wire [7:0] oneXg;
wire [7:0] oneXb;
reg 	[31:0] shift_oneXr ;
reg 	[31:0] shift_oneXg ;
reg 	[31:0] shift_oneXb ;

assign oneXr = QVAL - r;
assign oneXg = QVAL - g;
assign oneXb = QVAL - b;
// p1
reg [7:0] p1_r;
reg [7:0] p1_g;
reg [7:0] p1_b;
// pmap
reg [7:0] pmap_r;
reg [7:0] pmap_g;
reg [7:0] pmap_b;
// x2
reg [7:0] x2_r;
reg [7:0] x2_g;
reg [7:0] x2_b;
// x4
reg [7:0] x4_r;
reg [7:0] x4_g;
reg [7:0] x4_b;
// h1
reg [7:0] h1_r;
reg [7:0] h1_g;
reg [7:0] h1_b;
// hmap
reg [9:0] hmap_r;
reg [9:0] hmap_g;
reg [9:0] hmap_b;
// Iloc1
reg [15:0] Iloc1_r; // Q8.8 -> Q16.0
reg [15:0] Iloc1_g;
reg [15:0] Iloc1_b;
// Iloc2
reg [17:0] Iloc2_r; // Q8.8 -> Q18.0
reg [17:0] Iloc2_g;
reg [17:0] Iloc2_b;
reg [17:0] Iloc2_r_d; // Q8.8 -> Q18.0
reg [17:0] Iloc2_g_d;
reg [17:0] Iloc2_b_d;
// Iloc3 ï¼? cq + Iloc1
reg [16:0] Iloc3_r; // Q8.8 -> Q17.0
reg [16:0] Iloc3_g;
reg [16:0] Iloc3_b;
// Iloc4 : æ¯”è¾ƒIloc3 å’? Iloc2_d
reg [16:0] Iloc4_r  ;
reg [16:0] Iloc4_g  ;
reg [16:0] Iloc4_b  ;
// Iloc
reg [7:0] Iloc_r  ;
reg [7:0] Iloc_g  ;
reg [7:0] Iloc_b  ;
reg [7:0] Iloc_r_d  ;
reg [7:0] Iloc_g_d  ;
reg [7:0] Iloc_b_d  ;

// ctab å’? p_qæ‰?6æ‹? p_mapéœ?è¦æ‰“4æ‹?
reg [47:0] shift_ctab_r;
reg [47:0] shift_ctab_g;
reg [47:0] shift_ctab_b;
reg [95:0] shift_pq;
reg [31:0] shift_pmap_r;
reg [31:0] shift_pmap_g;
reg [31:0] shift_pmap_b;
// L2
reg [7:0] L2_r  ;
reg [7:0] L2_g  ;
reg [7:0] L2_b  ;
// p2_qæ‰?11æ‹?
reg [87:0] shift_p2q;

// Iglob
reg [15:0] Iglob1_r;
reg [15:0] Iglob1_g;
reg [15:0] Iglob1_b;
reg [15:0] Iglob2_r;
reg [15:0] Iglob2_g;
reg [15:0] Iglob2_b;
reg [8:0] Iglob3_r;
reg [8:0] Iglob3_g;
reg [8:0] Iglob3_b;
reg [7:0] Iglob_r;
reg [7:0] Iglob_g;
reg [7:0] Iglob_b;
// rgb
wire [23:0] rgb_tmp;
reg [13:0] shift_vs; 
reg [13:0] shift_hs; 
reg [13:0] shift_de; 
reg [87:0] shift_r;
reg [87:0] shift_g;
reg [87:0] shift_b;


always@(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		shift_oneXr	<= 'd0;
		shift_oneXg <= 'd0;
		shift_oneXb <= 'd0;
	end
	else begin
		shift_oneXr	<=	{shift_oneXr[23:0], oneXr};
		shift_oneXg <=  {shift_oneXg[23:0], oneXg};
		shift_oneXb <=  {shift_oneXb[23:0], oneXb};
	end
end
always@(posedge clk or negedge rst_n) begin // ctab å’? p_qæ‰?6æ‹?
	if(~rst_n) begin
		shift_ctab_r	<= 'd0;
		shift_ctab_g	<= 'd0;
		shift_ctab_b	<= 'd0;
		shift_pq		<= 'd0;
	end
	else begin
		shift_ctab_r	<=	{shift_ctab_r[39:0]	,r_ctab};
		shift_ctab_g	<=  {shift_ctab_g[39:0]	,g_ctab};
		shift_ctab_b	<=  {shift_ctab_b[39:0]	,b_ctab};
		shift_pq		<=	{shift_pq[79:0]	,p_q	};
	end
end
always@(posedge clk or negedge rst_n) begin // ctab å’? p_qæ‰?6æ‹?
	if(~rst_n)
		shift_p2q <= 'd0;
	else
		shift_p2q <= {shift_p2q[79:0],p2_q};
end

always@(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		shift_r <= 'd0;
		shift_g <= 'd0;
		shift_b <= 'd0;
	end
	else begin
		shift_r <=	{shift_r[79:0], r};
		shift_g <=  {shift_g[79:0], g};
		shift_b <=  {shift_b[79:0], b};
	end
end

// ============================================ //
// 1æ‹? 
always@(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		p1_r	<= 'd0;
		p1_g	<= 'd0;
		p1_b    <= 'd0;
	end
	else begin
		p1_r	<= r * oneXr >> SHIFT;
		p1_g    <= g * oneXg >> SHIFT;
		p1_b	<= b * oneXb >> SHIFT;
	end
end
// 1æ‹?
always@(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		pmap_r <= 'd0;
		pmap_g <= 'd0;
		pmap_b <= 'd0;
	end
	else begin
		pmap_r	<= p1_r * shift_oneXr[15:8] >> SHIFT;
		pmap_g  <= p1_g * shift_oneXg[15:8] >> SHIFT;
		pmap_b	<= p1_b * shift_oneXb[15:8] >> SHIFT;
	end
end
always@(posedge clk or negedge rst_n) begin // pmapæ‰?4æ‹?
	if(~rst_n) begin
		shift_pmap_r <= 'd0;
		shift_pmap_g <= 'd0;
		shift_pmap_b <= 'd0;
	end
	else begin
		shift_pmap_r <=	 {shift_pmap_r[23:0], pmap_r};
		shift_pmap_g <=  {shift_pmap_g[23:0], pmap_g};
		shift_pmap_b <=  {shift_pmap_b[23:0], pmap_b};
	end
end
// 1æ‹? ============= rgb éœ?è¦æ‰“3æ‹?
always@(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		x2_r <= 'd0;
		x2_g <= 'd0;
		x2_b <= 'd0;
	end
	else begin
		x2_r	<= shift_r[23:16] * shift_r[23:16] >> SHIFT;
		x2_g    <= shift_g[23:16] * shift_g[23:16] >> SHIFT;
		x2_b	<= shift_b[23:16] * shift_b[23:16] >> SHIFT;
	end
end
// 1æ‹?
always@(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		x4_r <= 'd0;
		x4_g <= 'd0;
		x4_b <= 'd0;
	end
	else begin
		x4_r	<= x2_r * x2_r >> SHIFT;
		x4_g    <= x2_g * x2_g >> SHIFT;
		x4_b	<= x2_b * x2_b >> SHIFT;
	end
end
// 1æ‹?
always@(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		h1_r <= 'd0;
		h1_g <= 'd0;
		h1_b <= 'd0;
	end
	else begin
		h1_r	<= x4_r * shift_oneXr[31:24] >> SHIFT;
		h1_g    <= x4_g * shift_oneXg[31:24] >> SHIFT;
		h1_b	<= x4_b * shift_oneXb[31:24] >> SHIFT;
	end
end
// 1æ‹?
always@(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		hmap_r <= 'd0;
		hmap_g <= 'd0;
		hmap_b <= 'd0;
	end
	else begin
		hmap_r	<= ALPHA_H_Q * h1_r >> SHIFT;
		hmap_g  <= ALPHA_H_Q * h1_g >> SHIFT;
		hmap_b	<= ALPHA_H_Q * h1_b >> SHIFT;
	end
end
// æˆªè‡³åˆ°è¿™é‡Œï¼Œc_tabå’Œp_qéœ?è¦æ‰“6æ‹ï¼Œp_mapéœ?è¦æ‰“4æ‹ï¼Œrgbå·²ç»æ‰“äº†6æ‹?

// 4æ‹?,è®¡ç®—Iloc
always@(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		Iloc1_r <= 'd0;
		Iloc1_g <= 'd0;
		Iloc1_b <= 'd0;
		Iloc2_r <= 'd0;
		Iloc2_g <= 'd0;
		Iloc2_b <= 'd0;
		Iloc2_r_d <= 'd0 ;
		Iloc2_g_d <= 'd0 ;
		Iloc2_b_d <= 'd0 ;
	end
	else begin
		Iloc1_r <= shift_pq[95:80] * shift_pmap_r[31:24] >> SHIFT;
		Iloc1_g <= shift_pq[95:80] * shift_pmap_g[31:24] >> SHIFT;
		Iloc1_b <= shift_pq[95:80] * shift_pmap_b[31:24] >> SHIFT;
		Iloc2_r <= shift_pq[95:80] * hmap_r >>SHIFT ;
		Iloc2_g <= shift_pq[95:80] * hmap_g >>SHIFT ;
		Iloc2_b <= shift_pq[95:80] * hmap_b >>SHIFT ;
		Iloc2_r_d <= Iloc2_r ;
		Iloc2_g_d <= Iloc2_g ;
		Iloc2_b_d <= Iloc2_b ;
	end
end
always@(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		Iloc3_r <= 'd0;
		Iloc3_g <= 'd0;
	    Iloc3_b <= 'd0;
	end
	else begin
		Iloc3_r <= shift_ctab_r[47:40] + Iloc1_r;
		Iloc3_g <= shift_ctab_g[47:40] + Iloc1_g;
	    Iloc3_b <= shift_ctab_b[47:40] + Iloc1_b;
	end		
end
always@(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		Iloc4_r <= 'd0;
		Iloc4_g <= 'd0;
	    Iloc4_b <= 'd0;
	end
	else begin
		if(Iloc3_r > Iloc2_r_d)
			Iloc4_r <= Iloc3_r - Iloc2_r_d;
		else
			Iloc4_r <= 'd0;
		if(Iloc3_g > Iloc2_g_d)
			Iloc4_g <= Iloc3_g - Iloc2_g_d;
		else
			Iloc4_g <= 'd0;
		if(Iloc3_b > Iloc2_b_d)
			Iloc4_b <= Iloc3_b - Iloc2_b_d;
		else
			Iloc4_b <= 'd0;
	end		
end
always@(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		Iloc_r <= 'd0;
		Iloc_g <= 'd0;
	    Iloc_b <= 'd0;
	end
	else begin
		if(Iloc4_r > QVAL)
			Iloc_r <= QVAL;
		else 
			Iloc_r <= Iloc4_r[7:0];
		if(Iloc4_g > QVAL)
			Iloc_g <= QVAL;
		else 
			Iloc_g <= Iloc4_g[7:0];
		if(Iloc4_b > QVAL)
			Iloc_b <= QVAL;
		else 
			Iloc_b <= Iloc4_b[7:0];
	end
end
// æˆªè‡³åˆ°è¿™é‡Œï¼Œrgbå·²ç»æ‰“äº†10æ‹?
// 1æ‹?
always@(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		L2_r <= 'd0;
		L2_g <= 'd0;
		L2_b <= 'd0;
		Iloc_r_d <= 'd0;
		Iloc_g_d <= 'd0;
		Iloc_b_d <= 'd0;
	end
	else begin
		L2_r	<= Iloc_r * Iloc_r >> SHIFT;
		L2_g    <= Iloc_g * Iloc_g >> SHIFT;
		L2_b	<= Iloc_b * Iloc_b >> SHIFT;
		Iloc_r_d <= Iloc_r;
		Iloc_g_d <= Iloc_g;
		Iloc_b_d <= Iloc_b;
	end
end
// æˆªè‡³åˆ°è¿™é‡Œï¼ŒIlocéœ?è¦æ‰“ä¸?æ‹ï¼Œp2_qéœ?è¦æ‰“11æ‹ï¼Œrgbå·²ç»æ‰“äº†11æ‹?
// 3æ‹?
always@(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		Iglob1_r	<= 'd0;
		Iglob1_g    <= 'd0;
		Iglob1_b    <= 'd0;
		Iglob2_r    <= 'd0;
		Iglob2_g    <= 'd0;
		Iglob2_b    <= 'd0;	
	end
	else begin
		Iglob1_r	<= (shift_r[87:80] >= 'd210)? (QVAL-shift_p2q[87:80]) * Iloc_r_d : QVAL *Iloc_r_d;
		Iglob1_g    <= (shift_g[87:80] >= 'd210)? (QVAL-shift_p2q[87:80]) * Iloc_g_d : QVAL *Iloc_g_d;
		Iglob1_b    <= (shift_b[87:80] >= 'd210)? (QVAL-shift_p2q[87:80]) * Iloc_b_d : QVAL *Iloc_b_d;
		Iglob2_r    <= (shift_p2q[87:80]) * L2_r;
		Iglob2_g    <= (shift_p2q[87:80]) * L2_g;
		Iglob2_b    <= (shift_p2q[87:80]) * L2_b;
	end
end
always@(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		Iglob3_r	<= 'd0;
		Iglob3_g    <= 'd0;
		Iglob3_b    <= 'd0;
	end
	else begin
		Iglob3_r	<= (Iglob1_r + Iglob2_r) >> SHIFT;
		Iglob3_g    <= (Iglob1_g + Iglob2_g) >> SHIFT;
		Iglob3_b    <= (Iglob1_b + Iglob2_b) >> SHIFT;
	end
end
always@(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		Iglob_r	   <= 'd0;
		Iglob_g    <= 'd0;
		Iglob_b    <= 'd0;
	end
	else begin
		if(Iglob3_r > QVAL)
			Iglob_r <= QVAL;
		else
			Iglob_r <= Iglob3_r[7:0];
		if(Iglob3_g > QVAL)
			Iglob_g <= QVAL;
		else
			Iglob_g <= Iglob3_g[7:0];
		if(Iglob3_b > QVAL)
			Iglob_b <= QVAL;
		else
			Iglob_b <= Iglob3_b[7:0];	
	end
end

// æˆªè‡³åˆ°è¿™é‡Œrgbå·²ç»æ‰“äº†14æ‹?
assign o_rgb = {Iglob_r,Iglob_g,Iglob_b};

always@(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		shift_vs <= 'd0;
		shift_hs <= 'd0;
		shift_de <= 'd0;
	end
	else begin
		shift_vs <=	 {shift_vs[12:0], i_vs};
		shift_hs <=  {shift_hs[12:0], i_hs};
		shift_de <=  {shift_de[12:0], i_de};
	end
end
assign o_vs = shift_vs[13];
assign o_hs = shift_hs[13];
assign o_de = shift_de[13];

c_tab inst_r(
	.clk	(clk),
	.idata  (r),
	.o_data  (r_ctab)
);
c_tab inst_g(
	.clk	(clk),
	.idata  (g),
	.o_data  (g_ctab)
);
c_tab inst_b(
	.clk	(clk),
	.idata  (b),
	.o_data  (b_ctab)
);
endmodule



