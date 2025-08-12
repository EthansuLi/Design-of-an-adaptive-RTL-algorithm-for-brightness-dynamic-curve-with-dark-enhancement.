`timescale 1ns / 1ps

//滑动条接口
module Slide_2to1_Video_Interface
#(
    parameter C_CLOCK_FREQ_HZ   = 148500000,    //输入时钟频率,默认148.5MHz
    parameter C_SLIDE_COLOR     = 24'h00_00_00, //滑动条颜色,默认黑色 24'h00_0000
    parameter C_SLIDE_STEP_US   = 10,           //滑动黑条步进一个像素时间, 默认10us
    parameter C_SLIDE_PWIDTH    = 5,            //滑动黑条像素宽度,默认5个像素
    parameter C_SLIDE_CWAIT_MS  = 1000          //滑动黑条滑动到一边结束之后,改变方向等待时间,默认1000ms
)
(
    input i_clk,                                //时钟信号
    input i_rstn,                               //复位信号, 低电平复位
    
	//----------------视频写通道----------------//
    //控制信号
    input i_vid_vde,                            //视频像素有效信号,高电平有效
    input i_vid_hsync,                          //视频行同步有效信号,1->0代表一行开始
    input i_vid_vsync,                          //视频场同步有效信号,1->0代表一帧开始
	
	//数据信号
    input [23:0]i_vid_data1,					//视频1像素信号,RGB888
    input [23:0]i_vid_data2,					//视频2像素信号,RGB888
    
	//----------------视频读通道----------------//
    //控制信号
    output o_vid_vde,                       	//视频像素有效信号, 高电平有效
    output o_vid_hsync,                     	//视频行同步有效信号
    output o_vid_vsync,                     	//视频场同步有效信号
	
	//数据信号
    output [23:0]o_vid_data                		//视频像素信号,RGB888
);
	//---------------配置参数区域---------------//
    //滑动条参数计算
    localparam SLIDE_STEP_CNT = C_CLOCK_FREQ_HZ / 1000000 * C_SLIDE_STEP_US; // 单步时间的时钟周期数
    localparam SLIDE_WAIT_CNT = C_CLOCK_FREQ_HZ / 1000 * C_SLIDE_CWAIT_MS;   // 等待时间的时钟周期数

	//---------------状态参数区域---------------//
	localparam ST_IDLE			= 0;			//初始化状态,等待计数
	localparam ST_START			= 1;			//起始状态,判断方向
	localparam ST_RIGHT			= 2;			//向右状态
	localparam ST_LEFT			= 3;			//向左状态
	localparam ST_END			= 4;			//结束状态
	
	//-----------------计数信号-----------------//
	reg [$clog2(SLIDE_WAIT_CNT):0]wait_cnt = 0;	//等待计数
    reg [$clog2(SLIDE_STEP_CNT):0]step_cnt = 0;	//步进计数
    
	//----------------状态机信号----------------//
	reg [2:0]state_current = 0;
	reg [2:0]state_next = 0;
	
	//----------------寄存器信号----------------//
	//控制寄存器
	reg reg_dir = 0;							//方向寄存器,0->从右向左;1->从左向右
    reg [11:0]reg_slide_pos = 0;				//滑动条水平位置寄存器
    reg [11:0]reg_pixel_pos = 0;				//像素水平位置寄存器
    
	//-----------------标志信号-----------------//
	reg flag_step = 0;							//步进标志,当步进计数结束后,该标志拉高
    reg flag_end = 0;							//结束标志
	
	//-----------------输出信号-----------------//
	//视频读通道--控制信号
    reg vid_vde_o = 0;
    reg vid_hsync_o = 0;
    reg vid_vsync_o = 0;
	
	//视频读通道--数据信号
    reg [23:0]vid_data_o = 0;
	
	//---------------输出信号连线---------------//
	//视频读通道--控制信号
	assign o_vid_vde = vid_vde_o;
	assign o_vid_hsync = vid_hsync_o;
	assign o_vid_vsync = vid_vsync_o;
	
	//视频读通道--数据信号
	assign o_vid_data = vid_data_o;
	
	//-------------输出信号处理区域-------------//
	//视频读通道--控制信号--像素有效信号
	always@(posedge i_clk or negedge i_rstn)begin
		if(i_rstn == 1'b0)vid_vde_o <= 1'b0;
		else vid_vde_o <= i_vid_vde;
	end
	
	//视频读通道--控制信号--行同步信号
	always@(posedge i_clk or negedge i_rstn)begin
		if(i_rstn == 1'b0)vid_hsync_o <= 1'b0;
		else vid_hsync_o <= i_vid_hsync;
	end
	
	//视频读通道--控制信号--场同步信号
	always@(posedge i_clk or negedge i_rstn)begin
		if(i_rstn == 1'b0)vid_vsync_o <= 1'b0;
		else vid_vsync_o <= i_vid_vsync;
	end
	
	//视频读通道--数据信号--像素信号
	always@(posedge i_clk or negedge i_rstn)begin
		if(i_rstn == 1'b0)vid_data_o <= 24'd0;
		else if(i_vid_vde == 1'b1 && reg_pixel_pos < reg_slide_pos)vid_data_o <= i_vid_data1;//右侧显示视频1
		else if(i_vid_vde == 1'b1 && reg_pixel_pos < reg_slide_pos + C_SLIDE_PWIDTH)vid_data_o <= C_SLIDE_COLOR;//中间滑动条
		else if(i_vid_vde == 1'b1)vid_data_o <= i_vid_data2;//左侧显示视频2
		else vid_data_o <= vid_data_o;
	end
	
	//----------------状态机区域----------------//
	//主状态机
	always@(*)begin
		case(state_current)
			//初始化状态:等待计数
			ST_IDLE:begin
				if(wait_cnt < SLIDE_WAIT_CNT)state_next <= ST_IDLE;//等待计数结束
				else state_next <= ST_START;
			end
			//起始状态,判断方向
			ST_START:begin
				if(reg_dir == 1'b0)state_next <= ST_LEFT;	//向左
				else state_next <= ST_RIGHT;				//向右
			end
			//向右状态
			ST_RIGHT:begin
				if(flag_end == 1'b1)state_next <= ST_END;
				else state_next <= ST_RIGHT;
			end
			//向左状态
			ST_LEFT:begin
				if(flag_end == 1'b1)state_next <= ST_END;
				else state_next <= ST_LEFT;
			end
			//结束状态
			ST_END:state_next <= ST_IDLE;
			default:state_next <= ST_IDLE;
		endcase
	end
	
	//状态转换
	always@(posedge i_clk or negedge i_rstn)begin
		if(i_rstn == 1'b0)begin
			state_current <= ST_IDLE;
		end else begin
			state_current <= state_next;
		end
	end
	
	//-------------状态任务处理区域-------------//
	//方向寄存器:0->从右向左;1->从左向右
	always@(posedge i_clk or negedge i_rstn)begin
        if(i_rstn == 1'b0)reg_dir <= 1'b0;
		else if(state_current == ST_END)reg_dir <= ~reg_dir;
		else reg_dir <= reg_dir;
	end
	
	//滑动条水平位置寄存器
	always@(posedge i_clk or negedge i_rstn)begin
        if(i_rstn == 1'b0)reg_slide_pos <= 12'd0;
		else if(state_current == ST_LEFT && flag_step == 1'b1)reg_slide_pos <= reg_slide_pos + 1;
		else if(state_current == ST_RIGHT && flag_step == 1'b1)reg_slide_pos <= reg_slide_pos - 1;
		else reg_slide_pos <= reg_slide_pos;
	end
	
	//像素水平位置寄存器
	always@(posedge i_clk or negedge i_rstn)begin
        if(i_rstn == 1'b0)reg_pixel_pos <= 12'd0;
		else if(i_vid_hsync == 1'b0)reg_pixel_pos <= 12'd0;
		else if(i_vid_vde == 1'b1)reg_pixel_pos <= reg_pixel_pos + 1;
		else reg_pixel_pos <= reg_pixel_pos;
	end
	
	//步进标志,当步进计数结束后,该标志拉高
	always@(posedge i_clk or negedge i_rstn)begin
        if(i_rstn == 1'b0)flag_step <= 1'b0;
		else if(step_cnt < SLIDE_STEP_CNT)flag_step <= 1'b0;
		else flag_step <= 1'b1;
	end
	
	//结束标志
	always@(posedge i_clk or negedge i_rstn)begin
        if(i_rstn == 1'b0)flag_end <= 1'b0;
		else if(state_current == ST_LEFT && reg_slide_pos < 1920 - C_SLIDE_PWIDTH)flag_end <= 1'b0;//还没到头
		else if(state_current == ST_LEFT)flag_end <= 1'b1;
		else if(state_current == ST_RIGHT && reg_slide_pos > 0)flag_end <= 1'b0;	//还没到头
		else if(state_current == ST_RIGHT)flag_end <= 1'b1;
		else flag_end <= 1'b0;
	end
						
	//-------------主要任务处理区域-------------//
	//等待计数
	always@(posedge i_clk or negedge i_rstn)begin
        if(i_rstn == 1'b0)wait_cnt <= 0;
		else if(state_current == ST_IDLE)wait_cnt <= wait_cnt + 1;
		else wait_cnt <= 0;
	end
	
	//步进计数
	always@(posedge i_clk or negedge i_rstn)begin
        if(i_rstn == 1'b0)step_cnt <= 0;
		else if(flag_step == 1'b0)step_cnt <= step_cnt + 1;
		else step_cnt <= 0;
	end

endmodule
