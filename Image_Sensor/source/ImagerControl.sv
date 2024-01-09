`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/16/2022 11:16:16 AM
// Design Name: 
// Module Name: ImageControl 
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module ImagerControl 
#(
    parameter BUF_NUM = 4
)
(
        // clock and reset 
        input logic sys_clk,
        input logic sys_rst_n,
        input logic img_rx_clk,
        input logic img_rx_rst_n,
        input logic x_clk,
        input logic x_rst,
        // image data
        input  logic [159:0] untapFifo_In,
        input  logic fifoVld,   
	    input  logic [12:0] currentline,
        input  logic [11:0] lineWidth,
		input  logic [15:0] imageRow,
        input  logic [15:0] imageCol,		
        output logic XHS,
        output logic XVS,
        output logic XTRIG,
        input  logic new_frame,	
        input  logic rawImageMode,
	    output logic [79:0] imageData,
	    output logic imageDataVld,
		input  logic [15:0] XceiverStatus,
		input  logic FPGASlaveMode,
		input  logic [15:0] exposureTime,
		// light source modulation
		output logic LEDEn,
		output logic MLLEn,
		output logic SLLEn,
		// Ports of Axi Slave Bus Interface S00_AXI	
		input logic   s00_axi_aclk,
	    input logic   s00_axi_aresetn,	
		input logic [7-1 : 0] s00_axi_awaddr,
		input logic [2 : 0] s00_axi_awprot,
		input logic  s00_axi_awvalid,
		output logic s00_axi_awready,
		input logic [32-1 : 0] s00_axi_wdata,
		input logic [(32/8)-1 : 0] s00_axi_wstrb,
		input logic  s00_axi_wvalid,
		output logic  s00_axi_wready,
		output logic [1 : 0] s00_axi_bresp,
		output logic  s00_axi_bvalid,
		input logic  s00_axi_bready,
		input logic [7-1 : 0] s00_axi_araddr,
		input logic [2 : 0] s00_axi_arprot,
		input logic  s00_axi_arvalid,
		output logic  s00_axi_arready,
		output logic [32-1 : 0] s00_axi_rdata,
		output logic [1 : 0] s00_axi_rresp,
		output logic  s00_axi_rvalid,
		input logic  s00_axi_rready

);
logic [31:0] reg_data_1;
logic [31:0] reg_data_2;
logic [31:0] reg_data_3;
logic [31:0] reg_data_4;
logic [31:0] reg_data_5;
logic [31:0] reg_data_6;
logic [31:0] reg_data_7;
logic [31:0] status_0;
logic [31:0] status_1;
logic [31:0] status_3;
logic [31:0] xferCnt;
logic [31:0] FOT;

assign status_1 [15:0] = XceiverStatus;
assign status_1 [27:16] = lineWidth;

// AXI bus interface
imager_S_AXI imager_S_AXI_inst (
		.S_AXI_ACLK(s00_axi_aclk),
		.S_AXI_ARESETN(s00_axi_aresetn),
		.S_AXI_AWADDR(s00_axi_awaddr),
		.S_AXI_AWPROT(s00_axi_awprot),
		.S_AXI_AWVALID(s00_axi_awvalid),
		.S_AXI_AWREADY(s00_axi_awready),
		.S_AXI_WDATA(s00_axi_wdata),
		.S_AXI_WSTRB(s00_axi_wstrb),
		.S_AXI_WVALID(s00_axi_wvalid),
		.S_AXI_WREADY(s00_axi_wready),
		.S_AXI_BRESP(s00_axi_bresp),
		.S_AXI_BVALID(s00_axi_bvalid),
		.S_AXI_BREADY(s00_axi_bready),
		.S_AXI_ARADDR(s00_axi_araddr),
		.S_AXI_ARPROT(s00_axi_arprot),
		.S_AXI_ARVALID(s00_axi_arvalid),
		.S_AXI_ARREADY(s00_axi_arready),
		.S_AXI_RDATA(s00_axi_rdata),
		.S_AXI_RRESP(s00_axi_rresp),
		.S_AXI_RVALID(s00_axi_rvalid),
		.S_AXI_RREADY(s00_axi_rready),
		// register
		.reg_data_1 (reg_data_1),
		.reg_data_2 (reg_data_2),
		.reg_data_3 (reg_data_3),
		.reg_data_4 (reg_data_4),
		.reg_data_5 (reg_data_5),
		.reg_data_6 (reg_data_6),
		.reg_data_7 (reg_data_7),
		.status_0   (status_0),
		.status_1   (status_1),
		.status_2   (xferCnt),
		.status_3   (status_3),
		.status_4   (FOT)
);
	
// register distribution
logic [15:0] Hperiod;
logic [15:0] VMAX;
logic [15:0] imageStartLine;
logic [15:0] next_frame_delay;
logic [15:0] triggerLowTime;
logic [15:0] triggerHighTime;
logic [2:0]  nextFrame_buf_sel;
logic triggerEnable, intExposure, slaveImagerEn;
logic        enableLED;
logic        enableMLL;
logic        enableSLL;
logic [6:0]  dutyCycleLED;
logic [6:0]  dutyCycleMLL;
logic [6:0]  dutyCycleSLL;
logic [23:0]  periodLED;
logic [23:0]  periodMLL;
logic [23:0]  periodSLL;

assign Hperiod          = reg_data_1[15:0];
assign VMAX             = reg_data_1[31:16];
assign imageStartLine   = (|reg_data_2[15:0]) ? reg_data_2[15:0]  : 'd1;
assign next_frame_delay = (|reg_data_3[31:16])? reg_data_3[31:16] : 'd1;
assign triggerEnable    = reg_data_3[1];
assign intExposure      = reg_data_3[2];
assign slaveImagerEn    = reg_data_3[3];
//assign nextFrame_buf_sel= reg_data_3[6:4];
assign triggerLowTime   = intExposure? reg_data_4[15:0] : exposureTime;
//assign triggerHighTime  = reg_data_4[31:16];

//assign dutyCycleLED     = reg_data_5[6:0]; 
//assign dutyCycleMLL     = reg_data_6[6:0];
//assign dutyCycleSLL     = reg_data_7[6:0];
//assign enableLED        = reg_data_5[7];
//assign enableMLL        = reg_data_6[7];
//assign enableSLL        = reg_data_7[7];
//assign periodLED        = reg_data_5[31:8];
//assign periodMLL        = reg_data_6[31:8];
//assign periodSLL        = reg_data_7[31:8];

// frame rst
logic frameRst;
always @ (posedge sys_clk, negedge sys_rst_n) begin
       if (~sys_rst_n) begin
	      frameRst  <= 1'b0;
	   end else begin	   
          frameRst  <= new_frame;
	   end 	  
end

// next frame
//logic next_frame;
//logic frameNxt;
//logic [7:0] nextFrame_buf = '0;

//always @ (posedge sys_clk) begin
//     frameNxt <= next_frame & (~FPGASlaveMode);
//     nextFrame <= frameRst | frameNxt;
//     nextFrame_buf <= {nextFrame_buf[6:0], nextFrame};
//end 

// CDC for new_frame signal   
logic new_frame_lat;
logic new_frame_fb_x,  new_frame_x_fbin,  new_frame_x; 
logic new_frame_fb_rx, new_frame_rx_fbin, new_frame_rx;

always @ (posedge sys_clk, negedge sys_rst_n) begin
     if (~sys_rst_n)
        new_frame_lat <= 1'b0;
     else if (frameRst)
        new_frame_lat <= 1'b1;
     else if (new_frame_fb_x & new_frame_fb_rx) 
        new_frame_lat <= 1'b0; 
end 

toggle_sync new_frame_x_sync (
       .sig_in(new_frame_lat),                    
       .clk_b (x_clk),      
       .rst_b (x_rst),       
       .pulse_sync(new_frame_x),
       .sig_sync (new_frame_x_fbin)	   
);

toggle_sync new_frame_sys_fb (
       .sig_in(new_frame_x_fbin),                    
       .clk_b (sys_clk),      
       .rst_b (~sys_rst_n),       
       .sig_sync(new_frame_fb_x)  
);

toggle_sync new_frame_rx_sync (
       .sig_in(new_frame_lat),                    
       .clk_b (img_rx_clk),      
       .rst_b (~img_rx_rst_n),       
       .pulse_sync(new_frame_rx),
       .sig_sync (new_frame_rx_fbin)	   
);

toggle_sync new_frame_sys_fb1 (
       .sig_in(new_frame_rx_fbin),                    
       .clk_b (sys_clk),      
       .rst_b (~sys_rst_n),       
       .sig_sync(new_frame_fb_rx)  
);

logic frameStart;
// image sensor trigger control
FrameTrigger FrameTrigger_inst(
     .img_rx_clk (img_rx_clk)
	,.img_rx_rst_n (img_rx_rst_n)
	,.sys_clk (sys_clk)
	,.sys_rst_n	(sys_rst_n)
	,.x_clk (x_clk)
	,.x_rst (x_rst)
	,.new_frame_x (new_frame_x)
	,.new_frame_rx (new_frame_rx)
    ,.frameStart (frameStart)
    ,.rawImageMode (rawImageMode)
    ,.FPGASlaveMode(FPGASlaveMode)
	,.imageStartLine(imageStartLine)
	,.currentline(currentline)
	,.imageRow   (imageRow)
    ,.Hperiod (Hperiod)
    ,.VMAX(VMAX)
    ,.XHS (XHS)
    ,.XVS (XVS)	  
    ,.triggerModeIn (triggerEnable)	
    ,.trigger_o(XTRIG)  
    ,.next_frame_delay (next_frame_delay)
    ,.triggerLowTime (triggerLowTime)
    ,.triggerHighTime(triggerHighTime)
    //,.multiShutter (multiShutter)
    ,.FOT(FOT)
);

// image fifo 
logic raw_empty;
logic rawImageRead;
logic [15:0] imageCol_;
logic [15:0] columnCnt;
logic [15:0] rowCnt;
logic [15:0] col_cnt_untap;
logic [15:0] row_cnt_untap;
logic endofRead;
assign status_0 = {rowCnt, columnCnt};// false path
assign status_3 = {row_cnt_untap,col_cnt_untap};
assign imageCol_= (imageCol < lineWidth) ? imageCol : lineWidth;
          
ImageOutIF ImageOutIF_inst (    
     .img_rx_clk   (img_rx_clk)
	,.img_rx_rst_n (img_rx_rst_n)
	,.sys_clk      (sys_clk)
	,.sys_rst_n	   (sys_rst_n)	
	,.new_frame_lat(new_frame_lat) 	
	,.new_frame    (frameRst)
	,.new_frame_rx (new_frame_rx)
    ,.untapFifo_In (untapFifo_In)
    ,.fifoVld      (fifoVld & frameStart)
	,.lineWidth    (lineWidth)
    ,.imageCol     (imageCol_)
	,.imageRow     (imageRow)
	,.columnCnt    (columnCnt)
	,.rowCnt       (rowCnt)
	,.col_cnt      (col_cnt_untap)
	,.row_cnt      (row_cnt_untap)
	,.imageData    (imageData)
	,.imageDataVld (imageDataVld)
    ,.untapOvfl    (status_1[28])	
  );	
 
// imager light source control
pwm_ctrl LEDLightDim 
(
    .dutyCycleIn(dutyCycleLED),
    .preScaleIn (periodLED),
    .enable     (enableLED),
    .forceON    (1'b0),
    .sys_clk    (sys_clk),
    .sys_rst    (sys_rst),
    .pwm        (LEDEn)
);  

pwm_ctrl MultiLaserLineDim
(
    .dutyCycleIn(dutyCycleMLL),
    .preScaleIn (periodMLL),
    .enable     (enableMLL),
    .forceON    (1'b0),
    .sys_clk    (sys_clk),
    .sys_rst    (sys_rst),
    .pwm        (MLLEn)
);    
  
pwm_ctrl SingleLaserLineDim
(
    .dutyCycleIn(dutyCycleSLL),
    .preScaleIn (periodSLL),
    .enable     (enableSLL),
    .forceON    (1'b0),
    .sys_clk    (sys_clk),
    .sys_rst    (sys_rst),
    .pwm        (SLLEn)
);   


endmodule 