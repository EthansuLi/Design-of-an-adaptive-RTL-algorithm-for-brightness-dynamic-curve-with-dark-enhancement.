`timescale 1ns / 1ps

module tb_top;

  // === 参数 ===
  localparam CLK_PERIOD = 10;   // 时钟周期
  localparam H_RES = 8;          // 水平分辨率（视频宽度）
  localparam V_RES = 8;          // 垂直分辨率（视频高度）
  localparam NPIX = H_RES * V_RES; // 测试像素个数
  
  // === 时钟与复位 ===
  reg clk = 0;
  reg rst_n = 0;

  always #(CLK_PERIOD/2) clk = ~clk;

  initial begin
    # (3*CLK_PERIOD) rst_n = 1;
  end

  // === 测试数据 ===
  reg [23:0] in_rgb [0:NPIX-1];   // 输入的 RGB 数据 (24 位)
  integer i;
  
  // 生成一些 RGB 数据，涵盖纯色、中间值和渐变色
  initial begin
    // 定义 RGB 输入数据（每个数据格式为 {R[7:0], G[7:0], B[7:0]}）
    in_rgb[0] = 24'hFF0000;  // 红色
    in_rgb[1] = 24'h00FF00;  // 绿色
    in_rgb[2] = 24'h0000FF;  // 蓝色
    in_rgb[3] = 24'hFFFF00;  // 黄色
    in_rgb[4] = 24'h00FFFF;  // 青色
    in_rgb[5] = 24'hFF00FF;  // 品红
    in_rgb[6] = 24'h800000;  // 深红
    in_rgb[7] = 24'h808000;  // 橄榄色
    in_rgb[8] = 24'h008080;  // 深青色
    in_rgb[9] = 24'h800080;  // 紫色
    in_rgb[10] = 24'hC0C0C0; // 银色
    in_rgb[11] = 24'h808080; // 灰色
    in_rgb[12] = 24'hA52A2A; // 棕色
    in_rgb[13] = 24'hF4A300; // 橙色
    in_rgb[14] = 24'hC71585; // 紫红色
    in_rgb[15] = 24'h006400; // 深绿色
    in_rgb[16] = 24'h7FFF00; // 黄绿色
    in_rgb[17] = 24'h9ACD32; // 黄绿色
    in_rgb[18] = 24'hB8860B; // 黄褐色
    in_rgb[19] = 24'h8B4513; // SaddleBrown
    in_rgb[20] = 24'hA52A2A; // 红褐色
    in_rgb[21] = 24'hE9967A; // 粉红色
    in_rgb[22] = 24'hD2691E; // 巧克力色
    in_rgb[23] = 24'h5F9EA0; // 蓝灰色
    in_rgb[24] = 24'hF08080; // 浅红色
    in_rgb[25] = 24'hADD8E6; // 淡蓝色
    in_rgb[26] = 24'hD3D3D3; // 浅灰色
    in_rgb[27] = 24'h90EE90; // 淡绿色
    in_rgb[28] = 24'h98FB98; // 春芽色
    in_rgb[29] = 24'hFF6347; // 番茄色
    in_rgb[30] = 24'hFFD700; // 金色
    in_rgb[31] = 24'hC71585; // 深紫红色
  end

  // === DUT 实例化 ===
  reg [23:0] in_data = 24'd0;
  reg in_de = 1'b0;
  reg in_vs = 1'b0;  // 垂直同步信号
  reg in_hs = 1'b0;  // 水平同步信号
  wire [23:0] out_rgb;
  wire out_de;

  top dut (
    .clk(clk),
    .rst_n(rst_n),
    .i_rgb(in_data),
    .i_de(in_de),
    .i_vs(in_vs),
    .i_hs(in_hs),
    .o_rgb(out_rgb),
    .o_de(out_de)
  );

  // === 生成行场信号 ===
  integer row, col;
  reg [7:0] current_row = 0;
  reg [7:0] current_col = 0;

  always @(posedge clk) begin
    if (!rst_n) begin
      current_row <= 0;
      current_col <= 0;
    end else begin
      if (current_col < H_RES) begin
        current_col <= current_col + 1;
      end else begin
        current_col <= 0;
        if (current_row < V_RES) begin
          current_row <= current_row + 1;
        end else begin
          current_row <= 0;
        end
      end
    end
  end

  // 水平同步信号（hs）
  always @(posedge clk) begin
    if (current_col == 0)
      in_hs <= 1'b1;  // 当列为 0 时，发出水平同步信号
    else
      in_hs <= 1'b0;
  end

  // 垂直同步信号（vs）
  always @(posedge clk) begin
    if (current_row == 0)
      in_vs <= 1'b1;  // 当行为 0 时，发出垂直同步信号
    else
      in_vs <= 1'b0;
  end

  // === 驱动像素数据 ===
  initial begin
    # (5*CLK_PERIOD);  // 等待一些时间让时钟和复位稳定
    for (i = 0; i < NPIX; i = i + 1) begin
      @(posedge clk);
      in_data <= in_rgb[i];
      in_de   <= 1'b1;   // 激活输入信号
      # (CLK_PERIOD);
    end
    in_de <= 1'b0;  // 完成输入数据传输
  end

  // === 生成输出数据 ===
  always @(posedge clk) begin
    if (out_de) begin
      // 这里可以选择不进行比对，直接输出处理后的数据
      $display("Pixel %0d: DUT Output = %h", current_row * H_RES + current_col, out_rgb);
    end
  end

endmodule
