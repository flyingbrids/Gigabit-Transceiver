`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/09/2022 11:42:41 AM
// Design Name: 
// Module Name: FrameTrigger
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
module FrameTrigger(
     input logic         img_rx_clk
	,input logic         img_rx_rst_n
	,input logic         sys_clk
	,input logic         sys_rst_n
	,input logic         x_clk
	,input logic         x_rst

	,input logic         new_frame_x
	,input logic         new_frame_rx
	,input logic  [15:0] imageRow
	,input logic  [15:0] imageStartLine
	,input logic  [12:0] currentline
    ,input logic  [15:0] Hperiod
    ,input logic  [15:0] VMAX
	,output logic        XHS
    ,output logic        XVS
    ,output logic        frameStart
    ,input  logic        rawImageMode
	,input  logic        FPGASlaveMode
    ,input  logic [15:0] next_frame_delay
    ,input  logic [15:0] triggerLowTime 
    ,input  logic [15:0] triggerHighTime
    ,input  logic        multiShutter
    ,input  logic        triggerModeIn
    ,output logic        trigger_o
    ,output logic [31:0] FOT
);

// trigger start 
logic triggerStart;
logic triggerStart_pulse = 1'b0;
logic triggerPreStart;
logic [15:0] triggerDelayCnt;
logic triggerMode;
logic frameIdle;
logic XHS_d = 1'b1; 
logic triggerStart_d = 1'b0;

always @ (posedge x_clk) begin
     XHS_d <= XHS;
     triggerStart_d <= triggerStart;
     triggerStart_pulse <= triggerStart & (~triggerStart_d); 
end

always @ (posedge x_clk, posedge x_rst) begin
       if (x_rst) begin 
	      triggerStart <= 1'b0;
	      triggerPreStart <= 1'b0;
	      triggerDelayCnt <= '0;
	   end else if (triggerMode) begin
	     if (new_frame_x) begin
	        triggerPreStart <= 1'b1;  
	        triggerDelayCnt <= '0;	    
	     end else if (triggerPreStart & frameIdle & (triggerDelayCnt == next_frame_delay) & (XHS & ~XHS_d)) begin
	        triggerDelayCnt <= '0;	 
	        triggerStart <= 1'b1;        
	        triggerPreStart <= 1'b0;	        
	     end else if (triggerPreStart & frameIdle & (triggerDelayCnt < next_frame_delay) & (XHS & ~XHS_d)) begin 
	        triggerDelayCnt <= triggerDelayCnt + 1'b1;    
	     end else if (~frameIdle)
	        triggerStart <= 1'b0;
	   end else begin
	      triggerStart <= 1'b0;
	      triggerPreStart <= 1'b0;
	      triggerDelayCnt <= '0;	    
	   end
end 

// image capture frame start
logic frameRequest, frameStartPre;
always @ (posedge img_rx_clk, negedge img_rx_rst_n) begin
         if (~img_rx_rst_n) begin
		     frameRequest <= 1'b0;
			 frameStartPre <= 1'b0;
			 frameStart <= 1'b0;
		 end else if (new_frame_rx) begin
		     frameRequest <= 1'b1;
			 frameStartPre <= 1'b0;
			 frameStart <= 1'b0;
		 end else begin
		     if (currentline + 1 == imageStartLine[12:0])
                frameStartPre <= frameRequest;
             else if (currentline == imageStartLine[12:0])
			    frameStart <= frameStartPre;
		     else if ((currentline == imageRow + imageStartLine[12:0]) & frameStart) begin
			     frameRequest <= 1'b0;
			     frameStartPre <= 1'b0;
			     frameStart <= 1'b0;		 
			 end 
		 end
end		 

// XHS and XVS statemachine  
enum logic [1:0] { IDLE      = 2'd0
                 , FRAME_TRI = 2'd1
                 , LINE_TRI  = 2'd2
                 , LINE_Stream = 2'd3
                 } streamState, streamState_d;

logic nextLine;
logic [15:0] lineCnt;
always @ (posedge x_clk, posedge x_rst) begin
      if (x_rst) begin 
         streamState <= IDLE;
      end else begin
         case (streamState)
         IDLE: begin
             streamState <= FRAME_TRI;
         end     
         FRAME_TRI: begin
              if (XHS_cnt == 16'd3)
                streamState <= LINE_Stream; 
         end
         LINE_Stream: begin
             if (nextLine) 
                streamState <=(lineCnt == VMAX)? IDLE : LINE_TRI;  
         end
         LINE_TRI: begin
              if  (~XHS &(XHS_cnt==16'd2))
                streamState <= LINE_Stream;  
         end
         endcase          
      end
end 

logic trigger_o_d;
logic lineCntEn, lineCntEn_d;
logic [31:0] timerCount;

always @ (posedge x_clk, posedge x_rst) begin
      if (x_rst) begin 
         streamState_d <= IDLE;
         lineCnt <= 16'd0;
         lineCntEn <= 1'b0;
         triggerMode <= 1'b1;
         trigger_o_d <= 1'b1;
         frameIdle <= 1'b1;
         lineCntEn_d <= 1'b0;
         timerCount <= '0;
         FOT <= '0;
      end else begin
         streamState_d <= streamState;
         trigger_o_d <= trigger_o;
         frameIdle <= (lineCnt == '0)? 1'b1 : 1'b0;
         lineCntEn_d <= lineCntEn;                  
         
         if (trigger_o & ~trigger_o_d)
             lineCntEn <= triggerMode;
         
         if (~lineCntEn & lineCntEn_d) begin
            FOT <= timerCount;
            timerCount <= '0;
         end else if (~trigger_o & trigger_o_d) begin
            timerCount <= 'd1;
         end else if (|timerCount)
            timerCount <= timerCount + 1'b1;
             
         if (streamState_d != streamState) begin
           if (streamState == IDLE) begin
             lineCnt <= 16'd0;
             triggerMode <= triggerModeIn;
           end else if (streamState == LINE_Stream) begin
             lineCnt <= (~triggerMode | lineCntEn )? lineCnt + 1'b1 : '0;
             lineCntEn <= (lineCnt == VMAX-1)? 1'b0: lineCntEn; 
           end  
         end 
      end
end
                 
logic [15:0] XHS_cnt;
logic [1:0]  XVS_d;
assign nextLine = (XHS_cnt == Hperiod - 1'b1)? 1'b1 : 1'b0;

always @ (posedge x_clk, posedge x_rst) begin
      if (x_rst) begin 
         XVS <= 1'b1;
         XHS <= 1'b1;
         XHS_cnt <= '0;
         XVS_d <= '1;
      end else begin
         XVS_d <= {XVS_d[0], XVS}; 
         case (streamState)
         IDLE: begin
               XVS <= 1'b1;
               XHS <= 1'b1;
               XHS_cnt <= '0;
         end         
         FRAME_TRI: begin
               XVS <= 1'b0;       
                             
               if ((XVS_d == '0) & (XHS_cnt == '0))
                   XHS <= 1'b0;
               else if (XHS_cnt == 16'd2)
                   XHS <= 1'b1;         
                   
               if (~XHS) 
                   XHS_cnt <=  XHS_cnt + 1'b1;
               else
                   XHS_cnt <= '0;
          end
          LINE_Stream: begin
                XHS_cnt <= XHS_cnt + 1'b1;
                XHS <= 1'b1;
          end 
          LINE_TRI: begin
                XVS <= 1'b1;
                XHS <= 1'b0;
                XHS_cnt <= XHS ? '0 : XHS_cnt + 1'b1;                
          end 
          endcase
       end
end 

// trigger control
logic [15:0] triggerTimeCnt_s;
logic trigger_s ,trigger_m;
always @ (posedge x_clk, posedge x_rst) begin
      if (x_rst) begin
          trigger_s <= 1'b1;
          triggerTimeCnt_s <= '0;
      end else if (trigger_s) begin
          trigger_s <= ~ (triggerStart_pulse & triggerMode);
          triggerTimeCnt_s <= '0;
      end else if (nextLine) begin
          triggerTimeCnt_s <= triggerTimeCnt_s + 1'b1;
          trigger_s <= (triggerTimeCnt_s == triggerLowTime - 1'b1)? 1'b1: trigger_s;
      end   
end      

always @ (posedge x_clk, posedge x_rst) begin
      if (x_rst) begin
          trigger_o <= 1'b1;
      end else if (~triggerMode) begin
          trigger_o <= 1'b1;
      end else if (XHS_cnt == Hperiod[15:1]) begin          
          trigger_o <= trigger_s;
      end 
end 
    
endmodule
